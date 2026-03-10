# ADR: Introduction of Per-Tenant Theme and Site Settings

- **Date**: 2025-12-27
- **Status**: Decided

## Context

### Background

The UserArea fan club site requires different designs for each tenant (artist).

Examples:
- **Kyary Pamyu Pamyu**: A pop design with a pink color scheme
- **Onokotogiku (Onoe Kikugoro)**: A subdued design with a navy and yellow color scheme

### Requirements

1. **Color scheme**: Apply different brand colors per tenant
2. **Fonts**: Apply different font families per tenant
3. **Labels**: Display names for features (NEWS vs. お知らせ, TICKET vs. お切符, BLOG vs. メッセージ)
4. **Feature enable/disable**: Select which features to display per tenant (e.g., whether SCHEDULE is shown)
5. **Landing page composition**: Section display order

### Relationship with the Future Dynamic Page System

As decided in ADR `20251225-user-area-alpha-namespace`, a dynamic page system backed by a `pages` table is planned for the future.

The dynamic page system will make the following configurable in the database:
- URL patterns
- Templates
- Content types to load
- Page-specific settings (labels, etc.)

With this future plan in mind, tenant settings need to be appropriately separated.

## Decision

**Separate tenant settings into two tables**:

### 1. `tenant_themes` Table

Manages site-wide style settings that are independent of individual pages.

```ruby
create_table :tenant_themes do |t|
  t.references :tenant, null: false, foreign_key: true, index: { unique: true }

  # Colors (output as CSS custom properties)
  t.string :color_primary        # --gearbox-primary
  t.string :color_primary_dark   # --gearbox-primary-dark
  t.string :color_secondary      # --gearbox-secondary
  t.string :color_on_primary     # --gearbox-on-primary
  t.string :color_background     # --gearbox-background
  t.string :color_surface        # --gearbox-surface
  t.string :color_text_primary   # --gearbox-text-primary
  t.string :color_text_secondary # --gearbox-text-secondary
  t.string :color_outline        # --gearbox-outline-primary

  # Fonts
  t.string :font_heading         # --gearbox-font-family-heading
  t.string :font_primary         # --gearbox-font-family-primary

  t.timestamps
end
```

**This table will be retained even after the future dynamic page system is introduced.**

### 2. `tenant_site_settings` Table

Provisionally manages feature settings and landing page composition that will eventually migrate to the `pages` table.

```ruby
create_table :tenant_site_settings do |t|
  t.references :tenant, null: false, foreign_key: true, index: { unique: true }

  # Feature settings (to be migrated to pages table in the future)
  t.jsonb :features, default: {}

  # Landing page settings (to be migrated to pages table in the future)
  t.jsonb :landing, default: {}

  # Authentication button labels
  t.string :login_label, default: 'ログイン'
  t.string :signup_label, default: '新規会員登録'

  t.timestamps
end
```

**This table will be removed after the `pages` table is introduced.**

### JSONB Column Structures

#### features

```json
{
  "news": {
    "enabled": true,
    "label": "お知らせ",
    "menu_label": "お知らせ",
    "show_in_landing": true,
    "landing_order": 1
  },
  "ticket": {
    "enabled": true,
    "label": "お切符",
    "menu_label": "お切符",
    "categories": [
      { "key": "performance", "label": "公演" },
      { "key": "tea_party", "label": "お茶会" },
      { "key": "other", "label": "その他" }
    ]
  },
  "blog": {
    "enabled": true,
    "label": "メッセージ",
    "menu_label": "メッセージ",
    "categories": [
      { "key": "main", "label": "本人ブログ" },
      { "key": "movie", "label": "ムービー" },
      { "key": "staff", "label": "スタッフ" }
    ]
  },
  "schedule": {
    "enabled": false
  },
  "profile": {
    "enabled": true,
    "label": "プロフィール",
    "show_in_landing": true
  }
}
```

#### landing

```json
{
  "sections_order": ["auth", "news", "blog", "profile"]
}
```

## Rationale

### Dynamic Generation of CSS Custom Properties

The layout template outputs values from `tenant_themes` as CSS custom properties:

```erb
<style>
  :root {
    --gearbox-primary: <%= current_tenant.theme&.color_primary || '#F2719D' %>;
    --gearbox-primary-dark: <%= current_tenant.theme&.color_primary_dark || '#D4567D' %>;
    /* ... */
  }
</style>
```

### Referencing Settings in Views

```erb
<%# Header menu %>
<% if feature_enabled?(:news) %>
  <a href="<%= user_area_news_index_path %>"><%= feature_label(:news, :menu_label) %></a>
<% end %>

<%# Login button %>
<a href="<%= user_area_auth_start_path %>">
  <%= current_site_settings.login_label %>
</a>
```

### Helper Methods

```ruby
module UserArea::SiteSettingsHelper
  def feature_enabled?(feature_key)
    current_site_settings.feature_enabled?(feature_key)
  end

  def feature_label(feature_key, label_type = :label)
    current_site_settings.feature_label(feature_key, label_type)
  end

  def feature_categories(feature_key)
    current_site_settings.feature_categories(feature_key)
  end
end
```

### Migration Path

```
┌─────────────────────────────────────────────────────────────┐
│  Phase 1: Current (alpha implementation)                    │
│  ┌─────────────────┐  ┌─────────────────────────────────┐  │
│  │ tenant_themes   │  │ tenant_site_settings            │  │
│  │ (colors, fonts) │  │ (features, landing) <- JSONB    │  │
│  └─────────────────┘  └─────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            |
                            v
┌─────────────────────────────────────────────────────────────┐
│  Phase 2: Dynamic page system introduction                  │
│  ┌─────────────────┐  ┌─────────────────────────────────┐  │
│  │ tenant_themes   │  │ pages                           │  │
│  │ (colors, fonts) │  │ (url, template, content_type,   │  │
│  │ <- retained     │  │  settings, enabled, order)      │  │
│  └─────────────────┘  └─────────────────────────────────┘  │
│                        ^                                    │
│                        Migrated from tenant_site_settings   │
│                        tenant_site_settings removed after   │
│                        migration                            │
└─────────────────────────────────────────────────────────────┘
```

## Impact

### Positive

- **Separation of concerns**: Clear separation between theme (appearance) and page composition (structure)
- **Future compatibility**: `tenant_themes` can be retained after the dynamic page system is introduced
- **Incremental migration**: Provisional implementation using JSONB makes it easy to migrate to a normalized schema later
- **Flexibility**: New tenants can be onboarded with database configuration alone

### Negative

- **JSONB type safety**: `features` and `landing` are JSONB columns, so schema validation is required
- **Dual management period**: Temporary data migration is needed when the dynamic page system is introduced
- **Complexity**: The logic for retrieving settings becomes somewhat more complex

### Risks

- Compatibility with existing data must be maintained when the JSONB structure changes
- Default value management (fallback when no value exists in the database)

## Related

- ADR: 20251225-user-area-alpha-namespace
- Design proposal: 251226t14_A案_斧琴菊_Haguruma_デザイン_提案書.pdf
