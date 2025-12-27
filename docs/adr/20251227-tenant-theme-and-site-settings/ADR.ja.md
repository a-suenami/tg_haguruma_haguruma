# テナント別テーマ・サイト設定の導入

## Status

Accepted

## Context

### 背景

UserArea のファンクラブサイトは、テナント（アーティスト）ごとに異なるデザインが必要である。

具体例:
- **きゃりーぱみゅぱみゅ**: ピンク基調のポップなデザイン
- **斧琴菊（尾上菊五郎）**: 紺・黄色基調の落ち着いたデザイン

### 要件

1. **カラースキーム**: テナントごとに異なるブランドカラーを適用
2. **フォント**: テナントごとに異なるフォントファミリーを適用
3. **ラベル**: 機能名の表示（NEWS vs お知らせ、TICKET vs お切符、BLOG vs メッセージ）
4. **機能の有効/無効**: テナントごとに表示する機能を選択（SCHEDULE の有無など）
5. **ランディングページ構成**: セクションの表示順序や外部リンクの設定

### 将来の動的ページシステムとの関係

ADR `20251225-user-area-alpha-namespace` で決定した通り、将来的には `pages` テーブルによる動的ページシステムを実装予定である。

動的ページシステムでは以下を DB で設定可能にする:
- URL パターン
- テンプレート
- ロードするコンテンツタイプ
- ページ固有の設定（ラベル等）

この将来計画を考慮し、テナント設定を適切に分離する必要がある。

## Decision

**テナント設定を2つのテーブルに分離する**:

### 1. `tenant_themes` テーブル

ページに依存しない、サイト全体のスタイル設定を管理する。

```ruby
create_table :tenant_themes do |t|
  t.references :tenant, null: false, foreign_key: true, index: { unique: true }

  # カラー（CSS カスタムプロパティとして出力）
  t.string :color_primary        # --gearbox-primary
  t.string :color_primary_dark   # --gearbox-primary-dark
  t.string :color_secondary      # --gearbox-secondary
  t.string :color_on_primary     # --gearbox-on-primary
  t.string :color_background     # --gearbox-background
  t.string :color_surface        # --gearbox-surface
  t.string :color_text_primary   # --gearbox-text-primary
  t.string :color_text_secondary # --gearbox-text-secondary
  t.string :color_outline        # --gearbox-outline-primary

  # フォント
  t.string :font_heading         # --gearbox-font-family-heading
  t.string :font_primary         # --gearbox-font-family-primary

  t.timestamps
end
```

**このテーブルは将来の動的ページシステム導入後も維持される。**

### 2. `tenant_site_settings` テーブル

機能設定・ランディングページ構成など、将来 `pages` テーブルに移行する設定を暫定的に管理する。

```ruby
create_table :tenant_site_settings do |t|
  t.references :tenant, null: false, foreign_key: true, index: { unique: true }

  # 機能設定（将来 pages テーブルに移行）
  t.jsonb :features, default: {}

  # ランディングページ設定（将来 pages テーブルに移行）
  t.jsonb :landing, default: {}

  # 認証ボタンラベル
  t.string :login_label, default: 'ログイン'
  t.string :signup_label, default: '新規会員登録'

  t.timestamps
end
```

**このテーブルは将来 `pages` テーブル導入後に削除される。**

### JSONB カラムの構造

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
  "sections_order": ["auth", "external_link", "news", "blog", "profile"],
  "external_link": {
    "show": true,
    "label": "オフィシャルサイトはこちら",
    "url": "https://example.com"
  }
}
```

## Implementation

### CSS カスタムプロパティの動的生成

レイアウトテンプレートで `tenant_themes` の値を CSS カスタムプロパティとして出力する:

```erb
<style>
  :root {
    --gearbox-primary: <%= current_tenant.theme&.color_primary || '#F2719D' %>;
    --gearbox-primary-dark: <%= current_tenant.theme&.color_primary_dark || '#D4567D' %>;
    /* ... */
  }
</style>
```

### ビューでの設定参照

```erb
<%# ヘッダーメニュー %>
<% if feature_enabled?(:news) %>
  <a href="<%= user_area_news_index_path %>"><%= feature_label(:news, :menu_label) %></a>
<% end %>

<%# ログインボタン %>
<a href="<%= user_area_auth_start_path %>">
  <%= current_site_settings.login_label %>
</a>
```

### ヘルパーメソッド

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

## Migration Path

```
┌─────────────────────────────────────────────────────────────┐
│  Phase 1: 現在（alpha 実装）                                 │
│  ┌─────────────────┐  ┌─────────────────────────────────┐  │
│  │ tenant_themes   │  │ tenant_site_settings            │  │
│  │ (colors, fonts) │  │ (features, landing) ← JSONB     │  │
│  └─────────────────┘  └─────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  Phase 2: 動的ページシステム導入                              │
│  ┌─────────────────┐  ┌─────────────────────────────────┐  │
│  │ tenant_themes   │  │ pages                           │  │
│  │ (colors, fonts) │  │ (url, template, content_type,   │  │
│  │ ← 維持          │  │  settings, enabled, order)      │  │
│  └─────────────────┘  └─────────────────────────────────┘  │
│                        ↑                                    │
│                        tenant_site_settings から移行        │
│                        移行後 tenant_site_settings 削除     │
└─────────────────────────────────────────────────────────────┘
```

## Consequences

### Positive

- **関心の分離**: テーマ（見た目）とページ構成（構造）を明確に分離
- **将来互換性**: `tenant_themes` は動的ページシステム導入後も維持可能
- **段階的移行**: JSONB で暫定実装し、将来の正規化されたスキーマに移行しやすい
- **柔軟性**: 新しいテナント追加時に DB 設定のみで対応可能

### Negative

- **JSONB の型安全性**: `features` と `landing` は JSONB のため、スキーマ検証が必要
- **二重管理期間**: 動的ページシステム導入時に一時的にデータ移行が必要
- **複雑性**: 設定の取得ロジックがやや複雑になる

### Risks

- JSONB 構造の変更時に既存データとの互換性維持が必要
- デフォルト値の管理（DB に値がない場合のフォールバック）

## References

- ADR: 20251225-user-area-alpha-namespace
- デザイン提案書: 251226t14_A案_斧琴菊_Haguruma_デザイン_提案書.pdf
