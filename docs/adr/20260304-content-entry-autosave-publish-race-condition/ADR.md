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

## Decision

### Fix 1 (this release): `BaseSaveFieldService` — Autosave only updates existing drafts

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

### Future direction: Deprecate the "Save" button

Since autosave already persists all changes automatically, the "Save" button is redundant and is the trigger that creates the race condition scenario described above (step T2). The button will be removed from the UI in a future release. Once removed, the race condition scenario itself can no longer occur.

## Rationale

### Why only Fix 1 was adopted

- Fix 1 fully prevents data loss (creation of empty drafts)
- Given the planned deprecation of the "Save" button, investing in additional defenses (pessimistic locking, frontend cancel) is unnecessary
- Clarifying `BaseSaveFieldService` as autosave-only (update, not create) aligns with the post-deprecation design

### Why pessimistic locking was not adopted

Fix 1 already prevents data loss. Locking would be excessive at this stage, and the race condition will be eliminated entirely once the "Save" button is removed.

### Why frontend autosave cancellation was not adopted

For the same reason. The scenario will be resolved structurally by removing the "Save" button, making the frontend change not worth the implementation cost.

### Why "copy published fields to a new draft" was not adopted

An alternative approach was considered: when autosave finds no draft after publish, copy the published version's fields into a new draft, then apply the autosaved field. This was rejected because:

- New drafts would be created at unintended times without user action
- `CreateDraftFromPublishedService` could be invoked on every autosave tick
- Added complexity with no valid use case — there is no legitimate reason to autosave a field to a new draft immediately after publishing

## Impact

- A "save failed" status may appear in the autosave indicator immediately after a publish operation. This is expected behavior.
- `BaseSaveFieldService`'s responsibility is clarified to "autosave only (update existing draft)".
- `SaveEntryService` continues to handle both creation and updating of drafts (no change).
- When the "Save" button is eventually removed, the draft creation logic in `SaveEntryService` will also need to be revisited.

## Related

- `app/services/admin_area/contents/base_save_field_service.rb` — fix target
- `app/services/admin_area/contents/save_entry_service.rb` — no change (to be revisited when "Save" button is removed)
