# HTML Block Feature Specification

---

## 1. Background & Purpose

Add an HTML Block feature to the WYSIWYG editor (Lexical).
This enables administrators to embed raw HTML within richtext content, supporting use cases such as external form embeds, custom widgets, and complex table layouts.

**Primary Use Case:**
```html
<!-- External ticket registration form embed -->
<form action="https://example.com/receptions/.../form" method="post">
  <input type="hidden" name="secret" value="ABC1234">
  <input type="submit" value="Register for Ticket">
</form>
```
→ Users see a "Register for Ticket" submit button that POSTs to the external URL on click.

---

## 2. Scope

### In Scope
- **Users**: All users (no role restriction)
- **Target fields**: All richtext fields (no per-field toggle)
- **Future extensibility**: Designed to support `field_type: :html` in the future

### Out of Scope
- Per-field / per-content-type enable/disable toggle UI
- Client-side HTML validation
- Nested HTML blocks (block inside block)
- Implementation of `field_type: :html` (future, not in this release)

---

## 3. Functional Requirements

### 3-1. Editor UI (Admin)

| # | Requirement |
|---|-------------|
| F1 | Add an HTML Block insert button to the Toolbar |
| F2 | Clicking the button inserts an HTML Block node into the editor |
| F3 | Display a textarea inside the block for editing raw HTML |
| F4 | Show a real-time preview below the textarea |
| F5 | Display a warning badge: "⚠ style attributes and script tags will be removed on save" |

### 3-2. Data Persistence

| # | Requirement |
|---|-------------|
| F6 | HTML Block is stored as an `html-block` node in the Lexical JSON `value` field |
| F7 | Sanitize HTML server-side on save |
| F8 | Return a `warning` in the JSON response if sanitization changed the content |
| F9 | Show `window.alert` to notify the user when a warning is received |

### 3-3. User-Facing Display

| # | Requirement |
|---|-------------|
| F10 | Render the HTML block as actual HTML on the user-facing site (not escaped) |
| F11 | Always sanitize before rendering (defense-in-depth) |

---

## 4. Security Requirements

### 4-1. Sanitization Spec

Uses `rails-html-sanitizer` (already in Gemfile.lock). Allowlist approach.

#### Allowed Tags

```
a abbr address article aside b blockquote br caption cite
code col colgroup data dd del details dfn div dl dt em
figcaption figure footer form h1 h2 h3 h4 h5 h6 header hr
i input ins kbd li main mark nav ol p pre q s samp section
small span strong sub summary sup table tbody td tfoot
th thead time tr u ul var
```

> `<form>` and `<input>` are allowed because external form embed is a core use case.

#### Allowed Attributes

```
accept-charset action alt class cite colspan data datetime
dir headers height href id lang method name rowspan scope
src start reversed title type value width
```

#### Removed Items

| Category | Example | Reason |
|----------|---------|--------|
| `style` attribute | `style="color:red"` | Prevent CSS injection |
| Event handler attributes | `onclick="..."`, `onsubmit="..."` | Prevent XSS |
| `<script>` tag | `<script>alert(1)</script>` | Prevent XSS |
| `<iframe>` tag | `<iframe src="...">` | Prevent clickjacking |
| `<object>` tag | `<object data="...">` | Prevent plugin abuse |

### 4-2. Double Sanitization

```
[On Save]   SaveRichtextFieldService → HtmlBlockSanitizer.sanitize → DB
[On Render] LexicalHelper#render_node → HtmlBlockSanitizer.sanitize → raw output
```

---

## 5. Data Flow

```
[Admin UI]
  HtmlBlockNode (textarea input)
    ↓ Lexical JSON serialize
  { type: "html-block", html: "<form>...</form>", version: 1 }
    ↓ HiddenFieldSyncPlugin → lexical:change event
  autosave_field_controller.ts
    ↓ PATCH /richtext_fields/:api_identifier  { value: JSON }
  SaveRichtextFieldService#save_field_value
    ↓ HtmlBlockSanitizer.sanitize (scan html-block nodes)
  ContentEntry::FieldRichtext (saved to DB)
    ↓ JSON response { success, saved_at, warning? }
  autosave_field_controller.ts
    ↓ if warning → window.alert("...")

[User Site]
  ContentEntry::FieldRichtext#value (JSON)
    ↓ LexicalHelper#lexical_to_html
  html-block node → HtmlBlockSanitizer.sanitize → .html_safe
    ↓ raw() in view
  Rendered as actual HTML
```

---

## 6. Acceptance Criteria

### AC1: Inserting and Editing HTML Block
- [ ] "HTML" button appears in the Toolbar
- [ ] Clicking inserts an HTML block into the editor
- [ ] HTML can be typed into the textarea
- [ ] Real-time preview is displayed

### AC2: External Form Embed
- [ ] The following HTML can be entered and saved:
  ```html
  <form action="https://example.com/post" method="post">
    <input type="hidden" name="secret" value="ABC1234">
    <input type="submit" value="Register for Ticket">
  </form>
  ```
- [ ] Displayed as a submit button on the user-facing site
- [ ] Clicking the button POSTs to the external URL

### AC3: Sanitization Behavior
- [ ] Saving HTML with a `style` attribute strips the `style` attr
- [ ] `window.alert` is shown after save ("Some tags or attributes in the HTML block were removed for security...")
- [ ] `<script>` tag is removed
- [ ] Event handler attributes (e.g., `onclick`) are removed
- [ ] Safe tags (e.g., `<div>`, `<table>`) are preserved

### AC4: User-Side Rendering
- [ ] HTML block renders as real HTML, not as escaped text
- [ ] `<h1>Hello</h1>` renders as a heading (not as literal `&lt;h1&gt;Hello&lt;/h1&gt;`)

### AC5: Validation
- [ ] Lexical JSON containing an `html-block` node passes validation

---

## 7. Test Specification

### 7-1. Unit Tests

| Test Case | Expected Result |
|-----------|----------------|
| Input containing `<script>` tag | `<script>` tag is removed |
| Input with `style` attribute | `style` attr is removed |
| Input with `onclick` attribute | `onclick` attr is removed |
| Input containing `<iframe>` tag | `<iframe>` tag is removed |
| Input with `<form>` + `<input>` | `form`, `input`, `action`, `type`, `value` are preserved |
| Input containing `<table>` tag | `table`, `tr`, `td` are preserved |
| Input with `input type="hidden"` | `name` and `value` attributes are preserved |
| Changed content → `changed?` | Returns `true` |
| Unchanged content → `changed?` | Returns `false` |

### 7-2. Integration Tests

| Test Case | Expected Result |
|-----------|----------------|
| Save richtext with html-block (no sanitization change) | JSON response with `warning: nil` |
| Save richtext with html-block (style attr present) | `style` stripped + `warning: "html_sanitized"` in response |
| Lexical JSON with `html-block` node validation | Validation passes |

### 7-3. Manual Test Procedure

1. Open a content entry with a richtext field in the admin panel.
2. Click the "HTML" button in the Toolbar → verify an HTML block is inserted.
3. Enter the following HTML and wait for autosave:
   ```html
   <form action="https://example.com/post" method="post">
     <input type="hidden" name="secret" value="ABC1234">
     <input type="submit" value="Register for Ticket">
   </form>
   ```
   → Verify saved without alert.
4. Enter `<div style="color:red">test</div>` and save → verify alert is shown.
5. Open the user-facing site and verify the HTML renders correctly (form button is visible and functional).

### 7-4. Run Commands

```bash
# Unit test
source env.sh && bundle exec rails test test/services/html_block_sanitizer_test.rb

# Type check
source env.sh && srb tc .

# Lint
rubocop -A
```

---

## 8. Implementation File List

| File | Change |
|------|--------|
| `app/services/html_block_sanitizer.rb` | New |
| `app/frontend/components/HtmlBlockNode.tsx` | New |
| `test/services/html_block_sanitizer_test.rb` | New |
| `app/validators/lexical_json_validator.rb` | Modify |
| `app/helpers/lexical_helper.rb` | Modify |
| `app/services/admin_area/contents/base_save_field_service.rb` | Modify |
| `app/services/admin_area/contents/save_richtext_field_service.rb` | Modify |
| `app/controllers/admin_area/contents/collection/entries/base_field_controller.rb` | Modify |
| `app/frontend/components/ToolbarPlugin.tsx` | Modify |
| `app/frontend/components/LexicalEditor.tsx` | Modify |
| `app/frontend/controllers/autosave_field_controller.ts` | Modify |

---

## 9. Future Extension Design

- `HtmlBlockSanitizer` is designed as a standalone service → reusable for future `field_type: :html`
- `html-block` handling in `LexicalHelper` is extracted to a private method for isolation
- To add per-field toggle in the future: add `html_block_enabled` column to `content_type_field_richtexts` (same pattern as `FieldSelect#display_format`)
