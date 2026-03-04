# HTML Block (Liquid Template) Feature Specification

---

## 1. Background & Purpose

Add an HTML Block feature to the WYSIWYG editor (Lexical).
This enables administrators to embed HTML with Liquid templates within richtext content, supporting use cases such as external form embeds, custom widgets, and dynamic user-specific content.

**Use Cases:**

Example 1: POST Authentication (Ticket Playguide Integration)
```liquid
<!-- Embed user.id in the form tag issued by the playguide -->
<form method="post" action="https://ticket-site.com/xxxxxxxxx">
  <input type="hidden" name="company_id" value="1234567890">
  <input type="hidden" name="user_id" value="{{ user.id }}">
  <input type="submit" value="Apply for Ticket">
</form>
```
→ Users see an "Apply for Ticket" button that POSTs to the playguide with the logged-in user's ID


---

## 2. Scope

### In Scope
- **Users**: All users (no role restriction)
- **Target fields**: All richtext fields (no per-field toggle)
- **Template engine**: Liquid (`liquid` gem)
- **Initial variable scope**: User information (`user`)
- **Future extensibility**: Designed to support `field_type: :html` and expanded variable scope in the future

### Out of Scope
- Per-field / per-content-type enable/disable toggle UI
- Client-side HTML validation
- Nested HTML blocks (block inside block)
- Implementation of `field_type: :html` (future, not in this release)
- Variables beyond user information (site settings, other collections — future expansion)

---

## 3. Functional Requirements

### 3-1. Editor UI (Admin)

| # | Requirement |
|---|-------------|
| F1 | Add an HTML Block insert button to the Toolbar |
| F2 | Clicking the button inserts an HTML Block node into the editor |
| F3 | Display a textarea inside the block for editing HTML/Liquid templates |
| F4 | Show a real-time preview below the textarea (Liquid tags rendered with sample data) |
| F5 | Display a warning badge: "⚠ script tags and event handlers will be removed on save" |
| F5a | Display a list of available Liquid variables (e.g., `{{ user.id }}`) |

### 3-2. Data Persistence

| # | Requirement |
|---|-------------|
| F6 | HTML Block is stored as an `html-block` node in the Lexical JSON `value` field. Liquid templates are stored unrendered |
| F7 | Sanitize HTML server-side on save (Liquid tags are preserved as-is) |
| F8 | Return a `warning` in the JSON response if sanitization changed the content |
| F9 | Show `window.alert` to notify the user when a warning is received |

### 3-3. User-Facing Display

| # | Requirement |
|---|-------------|
| F10 | Render the HTML block as actual HTML on the user-facing site after Liquid template rendering (not escaped) |
| F11 | Always sanitize after Liquid rendering before output (defense-in-depth) |
| F12 | Variables available during Liquid rendering: `user` (current user information) |

---

## 4. Security Requirements

### 4-1. Sanitization Policy

CMS administrators are trusted users. Therefore, **minimal sanitization** is applied — only script execution is blocked.
Uses `rails-html-sanitizer` (already in Gemfile.lock). Blocklist approach.

#### Removed Items

| Category | Example | Reason |
|----------|---------|--------|
| `<script>` tag | `<script>alert(1)</script>` | Prevent XSS |
| Event handler attributes | `onclick="..."`, `onsubmit="..."`, `onerror="..."` | Prevent XSS |
| `<object>` tag | `<object data="...">` | Legacy, no valid use case |
| `<embed>` tag | `<embed src="...">` | Legacy, no valid use case |

#### Allowed Items

| Category | Example | Reason |
|----------|---------|--------|
| `<iframe>` tag | `<iframe src="https://www.youtube.com/...">` | External content embedding is a core CMS use case |
| `style` attribute | `style="color:red"` | Custom layout and styling is expected in a CMS |
| `<form>` + `<input>` | `<form action="...">` | External form embedding is a core use case |
| All other tags/attributes | `<div>`, `<table>`, `class`, `id`, etc. | Everything not in the blocklist above is allowed |

### 4-2. Double Sanitization

```
[On Save]   SaveRichtextFieldService → HtmlBlockSanitizer.sanitize → DB
[On Render] LexicalHelper#render_node → HtmlBlockSanitizer.sanitize → raw output
```

---

## 5. Data Flow

```
[Admin UI]
  HtmlBlockNode (textarea input — HTML + Liquid template)
    ↓ Lexical JSON serialize
  { type: "html-block", html: "<p>{{ user.name }}</p>", version: 1 }
    ↓ HiddenFieldSyncPlugin → lexical:change event
  autosave_field_controller.ts
    ↓ PATCH /richtext_fields/:api_identifier  { value: JSON }
  SaveRichtextFieldService#save_field_value
    ↓ HtmlBlockSanitizer.sanitize (Liquid tags preserved, only scripts removed)
  ContentEntry::FieldRichtext (saved to DB — Liquid template as-is)
    ↓ JSON response { success, saved_at, warning? }
  autosave_field_controller.ts
    ↓ if warning → window.alert("...")

[User Site]
  ContentEntry::FieldRichtext#value (JSON)
    ↓ LexicalHelper#lexical_to_html
  html-block node
    ↓ Liquid::Template.parse(html).render({ "user" => current_user_drop })
    ↓ HtmlBlockSanitizer.sanitize
    ↓ .html_safe
    ↓ raw() in view
  Rendered as actual HTML
```

### 5-2. Liquid Variable Scope

| Variable | Content | Example |
|----------|---------|---------|
| `user.id` | User ID | `{{ user.id }}` → `"abc123"` |

> When adding variables such as `site`, `entry`, `collections` in the future, extend the context hash passed to `HtmlBlockLiquidRenderer` — no structural changes needed.

### 5-3. Liquid Safety

Liquid is a sandboxed template engine with the following properties:
- Arbitrary Ruby code execution is **impossible**
- File system and network access is **impossible**
- Only explicitly passed variables are available in templates
- Built-in protection against infinite loops (enabled by default)

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

### AC2a: Liquid Template Dynamic Rendering
- [ ] An HTML block containing `{{ user.id }}` can be saved
- [ ] On the user-facing site, `{{ user.id }}` is replaced with the logged-in user's ID
- [ ] When not logged in, the `user` variable is treated as empty

### AC3: Sanitization Behavior
- [ ] `<script>` tag is removed
- [ ] Event handler attributes (e.g., `onclick`) are removed
- [ ] `window.alert` is shown after save when sanitization changed the content
- [ ] `style` attribute is preserved as-is
- [ ] `<iframe>` tag is preserved as-is
- [ ] Safe tags (e.g., `<div>`, `<table>`, `<form>`) are preserved

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
| Input with `onclick` attribute | `onclick` attr is removed |
| Input with `onerror` attribute | `onerror` attr is removed |
| Input containing `<object>` tag | `<object>` tag is removed |
| Input containing `<embed>` tag | `<embed>` tag is removed |
| Input with `style` attribute | `style` attr is preserved |
| Input containing `<iframe>` tag | `<iframe>` tag is preserved |
| Input with `<form>` + `<input>` | `form`, `input`, `action`, `type`, `value` are preserved |
| Input containing `<table>` tag | `table`, `tr`, `td` are preserved |
| Input with Liquid tag `{{ user.id }}` | Liquid tag is preserved as-is (not removed by sanitization) |
| Changed content → `changed?` | Returns `true` |
| Unchanged content → `changed?` | Returns `false` |

### 7-1a. Liquid Rendering Tests

| Test Case | Expected Result |
|-----------|----------------|
| Template with `{{ user.id }}` | Replaced with user ID |
| User is nil | Liquid tags replaced with empty string (no error) |
| Invalid Liquid syntax | `Liquid::SyntaxError` caught, template output as HTML-escaped text |

### 7-2. Integration Tests

| Test Case | Expected Result |
|-----------|----------------|
| Save richtext with html-block (no sanitization change) | JSON response with `warning: nil` |
| Save richtext with html-block (script tag present) | `script` stripped + `warning: "html_sanitized"` in response |
| Save richtext with html-block (style attr present) | `style` preserved + `warning: nil` in response |
| Save richtext with html-block (Liquid tags present) | Liquid tags preserved + `warning: nil` in response |
| Lexical JSON with `html-block` node validation | Validation passes |
| User-facing display (Liquid template + user) | Liquid rendered into HTML with user data |

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
4. Enter `<div style="color:red">test</div>` and save → verify saved without alert, style is preserved.
5. Enter `<iframe src="https://www.youtube.com/embed/xxx"></iframe>` and save → verify saved without alert.
6. Enter `<script>alert(1)</script>` and save → verify alert is shown and script is removed.
7. Enter `<input type="hidden" name="user_id" value="{{ user.id }}">` and save → verify saved without alert.
8. View the user-facing site while logged in → verify Liquid is rendered and user ID is embedded.

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
| `app/services/html_block_liquid_renderer.rb` | New |
| `app/drops/user_drop.rb` | New |
| `app/frontend/components/HtmlBlockNode.tsx` | New |
| `test/services/html_block_sanitizer_test.rb` | New |
| `test/services/html_block_liquid_renderer_test.rb` | New |
| `app/validators/lexical_json_validator.rb` | Modify |
| `app/helpers/lexical_helper.rb` | Modify |
| `app/services/admin_area/contents/base_save_field_service.rb` | Modify |
| `app/services/admin_area/contents/save_richtext_field_service.rb` | Modify |
| `app/controllers/admin_area/contents/collection/entries/base_field_controller.rb` | Modify |
| `app/frontend/components/ToolbarPlugin.tsx` | Modify |
| `app/frontend/components/LexicalEditor.tsx` | Modify |
| `app/frontend/controllers/autosave_field_controller.ts` | Modify |
| `Gemfile` | Modify (add `liquid` gem) |

---

## 9. Future Extension Design

- `HtmlBlockSanitizer` is designed as a standalone service → reusable for future `field_type: :html`
- `HtmlBlockLiquidRenderer` accepts variable scope as a hash → extend the context to add new variables
- `UserDrop` inherits `Liquid::Drop` and explicitly controls exposed properties → prevents leakage of sensitive user data (e.g., password_digest)
- `html-block` handling in `LexicalHelper` is extracted to a private method for isolation
- To add per-field toggle in the future: add `html_block_enabled` column to `content_type_field_richtexts` (same pattern as `FieldSelect#display_format`)
