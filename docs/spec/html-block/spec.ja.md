# HTMLブロック機能 要件定義

---

## 1. 背景・目的

WYSIWYGエディタ（Lexical）にHTMLブロック機能を追加する。
管理者がコンテンツ内に生のHTMLを埋め込めるようにすることで、外部フォーム、カスタムウィジェット、テーブル等の表現力を向上させる。

**想定ユースケース例：**
```html
<!-- チケット申込みフォームの埋め込み -->
<form action="https://example.com/receptions/.../form" method="post">
  <input type="hidden" name="secret" value="ABC1234">
  <input type="submit" value="チケット申込み">
</form>
```
→ ユーザーには「チケット申込み」ボタンが表示され、クリックで外部URLにPOSTされる

---

## 2. スコープ

### 対象
- **利用者**: 全ユーザー（権限制限なし）
- **対象フィールド**: 全richtextフィールド（per-field設定なし）
- **将来拡張**: HTML専用フィールド型（`field_type: :html`）の追加を考慮した設計

### スコープ外
- per-field・per-content-type での有効/無効切り替えUI
- クライアントサイドのHTMLバリデーション
- HTMLブロックのネスト（ブロック内ブロック）
- HTML専用フィールド型の実装（今回は対象外）

---

## 3. 機能要件

### 3-1. エディタUI（管理画面）

| # | 要件 |
|---|------|
| F1 | ToolbarにHTMLブロック挿入ボタンを追加する |
| F2 | ボタンクリックでエディタにHTMLブロックノードが挿入される |
| F3 | HTMLブロック内でHTML文字列を直接入力できるtextareaを表示する |
| F4 | textareaの下にリアルタイムプレビューを表示する |
| F5 | ブロック内に「⚠ style属性・scriptタグは保存時に除去されます」の注意文を表示する |

### 3-2. データ保存

| # | 要件 |
|---|------|
| F6 | HTMLブロックはLexical JSONの `html-block` ノードとして `value`（JSON）に保存される |
| F7 | 保存時にHTMLをサーバーサイドでサニタイズする |
| F8 | サニタイズにより内容が変化した場合、フロントエンドに `warning` を返す |
| F9 | `warning` を受信したら `window.alert` でユーザーに通知する |

### 3-3. ユーザーサイド表示

| # | 要件 |
|---|------|
| F10 | ユーザーサイドの記事表示でHTMLブロックを**実際のHTMLとして**レンダリングする（エスケープしない） |
| F11 | レンダリング前に必ずサニタイズを通す（二重防御） |

---

## 4. セキュリティ要件

### 4-1. サニタイズ仕様

`rails-html-sanitizer`（既存dep）を使用。ホワイトリスト方式。

#### 許可するタグ

```
a abbr address article aside b blockquote br caption cite
code col colgroup data dd del details dfn div dl dt em
figcaption figure footer form h1 h2 h3 h4 h5 h6 header hr
i input ins kbd li main mark nav ol p pre q s samp section
small span strong sub summary sup table tbody td tfoot
th thead time tr u ul var
```

> `<form>` と `<input>` を許可する理由：外部フォーム埋め込みはコアユースケースのため。

#### 許可する属性

```
accept-charset action alt class cite colspan data datetime
dir headers height href id lang method name rowspan scope
src start reversed title type value width
```

#### 除去されるもの（代表例）

| 種別 | 例 | 理由 |
|------|----|------|
| `style` 属性 | `style="color:red"` | CSS注入防止 |
| イベントハンドラ属性 | `onclick="..."`, `onsubmit="..."` | XSS防止 |
| `<script>` タグ | `<script>alert(1)</script>` | XSS防止 |
| `<iframe>` タグ | `<iframe src="...">` | クリックジャッキング防止 |
| `<object>` タグ | `<object data="...">` | プラグイン悪用防止 |

### 4-2. 保存と表示の二重サニタイズ

```
[保存時] SaveRichtextFieldService → HtmlBlockSanitizer.sanitize → DB保存
[表示時] LexicalHelper#render_node → HtmlBlockSanitizer.sanitize → raw出力
```

---

## 5. データフロー

```
[管理画面]
  HtmlBlockNode（textarea入力）
    ↓ Lexical JSON serialize
  { type: "html-block", html: "<form>...</form>", version: 1 }
    ↓ HiddenFieldSyncPlugin → lexical:change event
  autosave_field_controller.ts
    ↓ PATCH /richtext_fields/:api_identifier  { value: JSON }
  SaveRichtextFieldService#save_field_value
    ↓ HtmlBlockSanitizer.sanitize（html-blockノードを走査）
  ContentEntry::FieldRichtext（DB保存）
    ↓ JSON response { success, saved_at, warning? }
  autosave_field_controller.ts
    ↓ warning あり → window.alert("...")

[ユーザーサイト]
  ContentEntry::FieldRichtext#value（JSON）
    ↓ LexicalHelper#lexical_to_html
  html-block node → HtmlBlockSanitizer.sanitize → .html_safe
    ↓ raw() in view
  実際のHTMLとして表示
```

---

## 6. 受け入れ条件

### AC1: HTMLブロックの挿入・編集
- [ ] Toolbarに「HTML」ボタンが表示される
- [ ] クリックでエディタにHTMLブロックが挿入される
- [ ] textarea にHTMLを入力できる
- [ ] リアルタイムプレビューが表示される

### AC2: 外部フォームの埋め込み
- [ ] 以下のHTMLが入力・保存できる
  ```html
  <form action="https://example.com/post" method="post">
    <input type="hidden" name="secret" value="ABC1234">
    <input type="submit" value="チケット申込み">
  </form>
  ```
- [ ] ユーザーサイドで「チケット申込み」ボタンとして表示される
- [ ] ボタンクリックで外部URLにPOSTが送信される

### AC3: サニタイズ動作
- [ ] `style` 属性を含むHTMLを保存すると `style` が除去される
- [ ] 保存後にalertが表示される（「HTMLブロック内の一部の...」）
- [ ] `<script>` タグが除去される
- [ ] `onclick` 等のイベントハンドラが除去される
- [ ] 安全なタグ（`<div>`, `<table>` 等）は保持される

### AC4: ユーザーサイドレンダリング
- [ ] HTMLブロックが文字列としてではなく実際のHTMLとして表示される
- [ ] `<h1>Hello</h1>` が見出しとしてレンダリングされる

### AC5: バリデーション
- [ ] `html-block` ノードを含むLexical JSONがバリデーションを通過する

---

## 7. テスト仕様

### 7-1. ユニットテスト一覧

| テストケース | 期待結果 |
|-------------|---------|
| `<script>` タグを含む入力 | `script` タグが除去される |
| `style` 属性を含む入力 | `style` 属性が除去される |
| `onclick` 属性を含む入力 | `onclick` 属性が除去される |
| `<iframe>` タグを含む入力 | `iframe` タグが除去される |
| `<form>` + `<input>` を含む入力 | `form`, `input`, `action`, `type`, `value` が保持される |
| `<table>` タグを含む入力 | `table`, `tr`, `td` が保持される |
| `input type="hidden"` を含む入力 | `name` と `value` 属性が保持される |
| 変更あり → `changed?` | `true` を返す |
| 変更なし → `changed?` | `false` を返す |

### 7-2. 統合テスト一覧

| テストケース | 期待結果 |
|-------------|---------|
| richtext保存（html-block・変更なし） | `warning: nil` のJSONが返る |
| richtext保存（html-block・style属性あり） | `style` 除去 + `warning: "html_sanitized"` が返る |
| `html-block` ノードを含む Lexical JSON のバリデーション | バリデーション通過 |

### 7-3. 手動テスト手順

1. 管理画面でrichtext fieldを持つコンテンツエントリを開く
2. ToolbarのHTMLボタンをクリック → HTMLブロックが挿入されることを確認
3. 以下のHTMLを入力して自動保存を待つ：
   ```html
   <form action="https://example.com/post" method="post">
     <input type="hidden" name="secret" value="ABC1234">
     <input type="submit" value="チケット申込み">
   </form>
   ```
   → 警告なしで保存されることを確認
4. `<div style="color:red">test</div>` を入力して保存 → アラートが表示されることを確認
5. ユーザーサイドの表示でHTMLが機能することを確認

### 7-4. 実行コマンド

```bash
# ユニットテスト
source env.sh && bundle exec rails test test/services/html_block_sanitizer_test.rb

# Sorbet型チェック
source env.sh && srb tc .

# Lint
rubocop -A
```

---

## 8. 実装ファイル一覧

| ファイル | 変更種別 |
|----------|----------|
| `app/services/html_block_sanitizer.rb` | 新規 |
| `app/frontend/components/HtmlBlockNode.tsx` | 新規 |
| `test/services/html_block_sanitizer_test.rb` | 新規 |
| `app/validators/lexical_json_validator.rb` | 修正 |
| `app/helpers/lexical_helper.rb` | 修正 |
| `app/services/admin_area/contents/base_save_field_service.rb` | 修正 |
| `app/services/admin_area/contents/save_richtext_field_service.rb` | 修正 |
| `app/controllers/admin_area/contents/collection/entries/base_field_controller.rb` | 修正 |
| `app/frontend/components/ToolbarPlugin.tsx` | 修正 |
| `app/frontend/components/LexicalEditor.tsx` | 修正 |
| `app/frontend/controllers/autosave_field_controller.ts` | 修正 |

---

## 9. 将来的な拡張への設計方針

- `HtmlBlockSanitizer` は独立サービスとして設計 → 将来の `field_type: :html` でも再利用可能
- `LexicalHelper` の `html-block` ハンドリングは独立した private メソッドに分離
- per-field設定を追加する場合は `content_type_field_richtexts` に `html_block_enabled` カラムを追加（`FieldSelect#display_format` と同パターン）
