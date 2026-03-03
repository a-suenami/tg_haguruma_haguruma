# ADR: Fix Race Condition Between Content Entry Autosave and Publish

- **Date**: 2026-03-04
- **Status**: Decided

## Context

The content entry edit screen has two autosave mechanisms that save field changes automatically.

- **`autosave_field_controller.ts`**: Per-field autosave. Fires after a 1-second debounce on change, or immediately on focusout. Calls `PATCH /entries/:entry_id/fields/:api_identifier`, processed by `BaseSaveFieldService`.
- **`autosave_form_controller.ts`**: Full-form autosave. Fires on a 10-second interval, or immediately on focusout. Calls `PATCH /entries/:entry_id`, processed by `SaveEntryService`.

When an admin edits a published entry and quickly clicks "Save (draft)" then "Publish", the following race condition occurs:

```
T1: User modifies a field (autosave debounce starts, not yet fired)
T2: User clicks "Save" → SaveEntryService creates draft version N+1
T3: User clicks "Publish" → PublishEntryService transitions draft (status=1) to published (status=3)
T4: Autosave debounce completes, PATCH request fires
T5: BaseSaveFieldService calls find_by(status: :draft) → not found (already published)
T6: Creates a new empty draft at max_version + 1
T7: Only the one autosaved field is saved → title, images, and other fields are lost
```

The root cause is in the design of `BaseSaveFieldService#find_or_create_draft_version`. When no draft is found, it creates a new **empty draft** without checking for an existing published version or inheriting any of its fields.

```ruby
# Problematic code (base_save_field_service.rb)
def find_or_create_draft_version
  existing_draft = ContentEntry::Version.find_by(
    status: ContentEntry::Version::STATUSES[:draft], ...
  )
  return existing_draft if existing_draft

  # When called after publish, this creates an empty draft
  max_version = ContentEntry::Version.where(...).maximum(:version) || 0
  ContentEntry::Version.new(version: max_version + 1, status: :draft, ...).tap(&:save)
end
```

Additionally, there was no mutual exclusion between autosave and publish operations, leaving the system vulnerable to parallel execution.

## Decision

Implement a three-layer defense.

### Fix 1: `BaseSaveFieldService` — Autosave only updates existing drafts

Change `find_or_create_draft_version` so that it never creates a new draft. If no draft is found, return an error and roll back the transaction (silent failure).

```ruby
# After fix
def find_draft_version_or_fail
  draft = ContentEntry::Version.find_by(status: :draft, ...)
  unless draft
    @errors << '保存対象の下書きが見つかりません'
    raise ActiveRecord::Rollback
  end
  draft
end
```

Creating a new draft remains the sole responsibility of `SaveEntryService`, invoked only when the admin manually clicks "Save".

### Fix 2: Add Pessimistic Locking

Add `content_entry.lock!` (`SELECT FOR UPDATE` in PostgreSQL) at the start of the transaction in both `BaseSaveFieldService` and `PublishEntryService`.

```ruby
# BaseSaveFieldService#call
ActiveRecord::Base.transaction do
  @content_entry.lock!
  version = find_draft_version_or_fail
  # ...
end

# PublishEntryService#call
ActiveRecord::Base.transaction do
  @content_entry.lock!
  draft_version = find_draft_version
  # ...
end
```

**Effect:**
- If publish is running → autosave waits for the lock → after publish completes, autosave acquires the lock → no draft found → silently fails (Fix 1)
- If autosave is running → publish waits for the lock → after autosave completes, publish proceeds normally

This fix relies on PostgreSQL row-level locking (confirmed: both production and staging use PostgreSQL).

### Fix 3: Frontend — Cancel autosave on Save/Publish button click

Dispatch an `autosave:cancel` custom event when the "Save" or "Publish" button is clicked. Autosave controllers listen for this event and clear the debounce timer and abort any in-flight fetch request.

The current `autosave_field_controller.ts` uses `fetch()` without an `AbortController`, making it impossible to cancel requests already in-flight. An `AbortController` must be added.

```typescript
// autosave_field_controller.ts
private currentAbortController: AbortController | null = null;

cancelAutosave() {  // Handler for autosave:cancel event
  this.clearDebounce();
  this.currentAbortController?.abort();
  this.currentAbortController = null;
}

private async save() {
  this.currentAbortController = new AbortController();
  const response = await fetch(this.urlValue, {
    signal: this.currentAbortController.signal,
    // ...
  });
}
```

## Rationale

### Why Fix 1 is the top priority

- It directly addresses the root cause of data loss (missing fields)
- Consistent with the UX principle that autosave is a supplementary feature; silent failure immediately after a manual operation is acceptable
- Clearly separates responsibilities: `SaveEntryService` (manual save) creates drafts, `BaseSaveFieldService` (autosave) only updates them

### Why Fix 2 was adopted

- Combined with Fix 1, it guarantees that autosave will find no draft after publish completes
- Enforces operation ordering so that Fix 1's silent failure triggers at the right moment
- PostgreSQL `SELECT FOR UPDATE` is available in the production environment with low adoption cost

### Why Fix 3 was adopted

- Reduces the probability of the race condition occurring by addressing it at the source (frontend)
- Fixes 1 and 2 prevent damage when the race occurs; Fix 3 prevents the race from occurring at all — complementary layers of defense

### Why "copy published fields to a new draft" was not adopted

An alternative approach was considered: when autosave finds no draft after publish, copy the published version's fields into a new draft, then apply the autosaved field. This was rejected because:

- New drafts would be created at unintended times without user action
- `CreateDraftFromPublishedService` could be invoked on every autosave tick
- Added complexity with no valid use case — there is no legitimate reason to autosave a field to a new draft immediately after publishing

## Impact

- A "save failed" status may appear in the autosave indicator immediately after a publish operation. This is expected behavior.
- `BaseSaveFieldService`'s responsibility is clarified to "autosave only (update existing draft)".
- `SaveEntryService` continues to handle both creation and updating of drafts (no change).

## Related

- `app/services/admin_area/contents/base_save_field_service.rb` — primary fix target
- `app/services/admin_area/contents/publish_entry_service.rb` — lock addition target
- `app/services/admin_area/contents/save_entry_service.rb` — no change (retains draft creation responsibility)
- `app/frontend/controllers/autosave_field_controller.ts` — AbortController addition target
- `app/frontend/controllers/autosave_form_controller.ts` — cancel handling addition target
