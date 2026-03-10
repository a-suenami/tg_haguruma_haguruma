# テナントテーマ修正 ハンドオーバー

## PDF デザイン仕様書

**パス**: `/Users/suenami/Downloads/251226t14_A案_斧琴菊_Haguruma_デザイン_提案書.pdf`

### デザインコンセプト
「白と灰色をベースにブランドカラーである青と黄色を取り入れた落ち着きのあるデザイン」

### 色の使用箇所（PDF分析結果）

| 色 | 使用箇所 |
|----|----------|
| ネイビー (#1E3A5F) | ヒーロー背景、ヘッダー、filled ボタン背景、タイトルテキスト、ナビゲーション |
| ゴールド (#C9A227) | カテゴリラベルの背景 |
| 白 (#FFFFFF) | ページ背景、ネイビー上のテキスト |
| ライトグレー (#F8F8F8) | セクション背景、カード背景 |
| ダークグレー (#333333) | 本文テキスト |
| グレー (#666666) | 補助テキスト |
| ライトグレー (#E5E5E5) | 罫線、ボーダー |

### 機能ラベル（PDF より）
- news → 「お知らせ」
- ticket → 「お切符」
- blog → 「メッセージ」
- biography → 「プロフィール」（ページタイトルは「BIOGRAPHY」）
- **schedule は PDF に存在しない**

### 認証ボタンラベル
- ログイン: 「ログイン」
- 新規会員登録: 「新規会員登録」

---

## 指摘された問題点

### 1. CSS 変数名の不一致
**問題**: TenantTheme が出力する CSS 変数名と、gearbox SCSS が期待する変数名が異なる

| TenantTheme が出力していた | gearbox が期待する |
|---------------------------|-------------------|
| `--gearbox-text-primary` | `--gearbox-on-surface` |
| （なし） | `--gearbox-on-secondary` |
| （なし） | `--gearbox-secondary-container` |
| （なし） | `--gearbox-on-surface-rgb` |

**対応**: TenantTheme の css_custom_properties を修正して gearbox が期待する変数名を出力するようにした

### 2. gearbox における色の役割の誤解
**問題**: gearbox の `--gearbox-secondary` は「タイトル・ボタン・ナビゲーション」の色であり、単なるアクセント色ではない

```scss
// button.component.scss
--cog-button-filled-background-color: var(--gearbox-secondary);

// news-item.component.scss
.title { color: var(--gearbox-secondary); }

// tab.component.scss
color: var(--gearbox-secondary);
```

**gearbox のカラーマッピング**:
- `--gearbox-primary`: カテゴリラベル背景（アクセント）
- `--gearbox-secondary`: タイトル、ボタン、ナビゲーション（メインカラー）
- `--gearbox-on-surface`: 本文テキスト

### 3. TenantTheme にカラムが不足
**問題**: `color_on_secondary` カラムがなかった

**対応**: `db/schemas/tenant_themes.schema` に追加

### 4. TenantSiteSettings のデフォルト問題
**問題**: DEFAULT_FEATURES で全機能が `enabled: true` になっていたため、テナントが明示的に無効にしない限り SCHEDULE などが表示された

**対応**:
- 全機能を `enabled: false` に変更
- TenantSiteSettings がない場合は 404 になるべき（フォールバックを削除）

### 5. profile → biography リネーム
**問題**: PDF では「BIOGRAPHY」というページ名だが、コードでは `profile` だった

**対応**:
- TenantSiteSettings.DEFAULT_FEATURES で `profile` → `biography` に変更
- ヘッダーテンプレートの `:profile` → `:biography` に変更
- ルーティングは未対応（別途必要）

### 6. SVG タイトル画像の問題
**問題**: NEWS/BLOG/SCHEDULE の SVG タイトル画像に英語テキストがハードコードされていた

**対応**:
- `feature_title_svg` ヘルパーを削除
- `feature_label` を使用するように変更
- SVG ファイルを削除

### 7. SCSS からの色出力削除
**問題**: SCSS と Rails の両方から CSS 変数が出力され、Vite HMR で競合していた

**対応**:
- `app/frontend/styles/gearbox/shared/theme/colors/` ディレクトリを削除
- Rails (TenantTheme) のみから CSS 変数を出力

---

## 正しい dev-tenant 設定スクリプト

```ruby
t = Tenant.find('dev-tenant')

# Theme 設定
theme = t.theme || t.create_theme!
theme.update!(
  color_primary: '#C9A227',        # ゴールド - カテゴリラベル背景
  color_primary_dark: '#A68B1F',   # ダークゴールド
  color_secondary: '#1E3A5F',      # ネイビー - タイトル、ボタン、ナビ
  color_on_primary: '#1E3A5F',     # ネイビー - ゴールド上のテキスト
  color_on_secondary: '#FFFFFF',   # 白 - ネイビーボタン上のテキスト
  color_background: '#FFFFFF',     # 白
  color_surface: '#F8F8F8',        # ライトグレー
  color_text_primary: '#333333',   # ダークグレー - 本文
  color_text_secondary: '#666666', # グレー
  color_outline: '#E5E5E5',        # ライトグレー
  font_heading: 'Noto Sans JP',
  font_primary: 'Noto Sans JP'
)

# Site Settings 設定
settings = t.site_settings || t.create_site_settings!
settings.update!(
  login_label: 'ログイン',
  signup_label: '新規会員登録',
  features: {
    'news' => {
      'enabled' => true,
      'label' => 'お知らせ',
      'menu_label' => 'お知らせ',
      'show_in_landing' => true,
      'landing_order' => 1
    },
    'ticket' => {
      'enabled' => true,
      'label' => 'お切符',
      'menu_label' => 'お切符',
      'show_in_landing' => false,
      'landing_order' => 2
    },
    'blog' => {
      'enabled' => true,
      'label' => 'メッセージ',
      'menu_label' => 'メッセージ',
      'show_in_landing' => true,
      'landing_order' => 3
    },
    'biography' => {
      'enabled' => true,
      'label' => 'プロフィール',
      'menu_label' => 'プロフィール',
      'show_in_landing' => true,
      'landing_order' => 4
    }
    # schedule は含めない（無効）
  }
)
```

---

## 残作業

1. ~~**ridgepole:apply** - スキーマ変更を適用~~ ✅ 完了
2. **biography ルーティング** - `/biography` ルートとコントローラーの作成
3. ~~**モバイルメニューの biography 対応** - ヘッダーのモバイルメニュー部分も `:profile` → `:biography` に変更~~ ✅ 完了
4. **dev-tenant データ投入** - 上記スクリプトを実行

---

## 変更したファイル一覧

- `app/models/tenant_theme.rb` - css_custom_properties 修正
- `app/models/tenant_site_settings.rb` - DEFAULT_FEATURES 修正、profile → biography
- `app/helpers/user_area/site_settings_helper.rb` - フォールバック削除
- `app/helpers/svg_helper.rb` - feature_title_svg 削除
- `app/views/user_area/alpha/shared/_page_header.html.erb` - :profile → :biography
- `app/views/user_area/alpha/news/index.html.erb` - feature_label 使用
- `app/views/user_area/alpha/blog/index.html.erb` - feature_label 使用
- `app/views/user_area/alpha/schedules/index.html.erb` - feature_label 使用
- `app/views/user_area/alpha/root/index.html.erb` - feature_label 使用
- `db/schemas/tenant_themes.schema` - color_on_secondary 追加
- `app/frontend/styles/gearbox/shared/theme/colors/` - 削除
- `app/assets/images/features/` - 削除
