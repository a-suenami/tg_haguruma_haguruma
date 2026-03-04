# HTMLブロック（Liquid テンプレート）機能 要件定義

---

## 1. 背景・目的

WYSIWYGエディタ（Lexical）にHTMLブロック機能を追加する。
管理者がコンテンツ内にLiquidテンプレート付きのHTMLを埋め込めるようにすることで、外部フォーム、カスタムウィジェット、ユーザーごとの動的コンテンツ等の表現力を向上させる。

**想定ユースケース例：**

例1: POST認証（チケットプレイガイド連携）
```liquid
<!-- プレイガイドから発行されるフォームタグに user.id を埋め込み -->
<form method="post" action="https://ticket-site.com/xxxxxxxxx">
  <input type="hidden" name="company_id" value="1234567890">
  <input type="hidden" name="user_id" value="{{ user.id }}">
  <input type="submit" value="チケットを申し込む">
</form>
```
→ ユーザーには「チケットを申し込む」ボタンが表示され、クリックでログインユーザーの ID 付きでプレイガイドにPOSTされる


---

## 2. スコープ

### 対象
- **利用者**: 全ユーザー（権限制限なし）
- **対象フィールド**: 全richtextフィールド（per-field設定なし）
- **テンプレートエンジン**: Liquid（`liquid` gem）
- **初期の変数スコープ**: ユーザー情報（`user`）
- **将来拡張**: HTML専用フィールド型（`field_type: :html`）の追加、変数スコープの拡大を考慮した設計

### スコープ外
- per-field・per-content-type での有効/無効切り替えUI
- クライアントサイドのHTMLバリデーション
- HTMLブロックのネスト（ブロック内ブロック）
- HTML専用フィールド型の実装（今回は対象外）
- ユーザー情報以外の変数（サイト設定、他コレクション等は将来拡張）

---

## 3. 機能要件

### 3-1. エディタUI（管理画面）

| # | 要件 |
|---|------|
| F1 | ToolbarにHTMLブロック挿入ボタンを追加する |
| F2 | ボタンクリックでエディタにHTMLブロックノードが挿入される |
| F3 | HTMLブロック内でHTML/Liquidテンプレートを直接入力できるtextareaを表示する |
| F4 | textareaの下にリアルタイムプレビューを表示する（Liquid タグはサンプルデータでレンダリング） |
| F5 | ブロック内に「⚠ scriptタグ・イベントハンドラは保存時に除去されます」の注意文を表示する |
| F5a | 利用可能な Liquid 変数の一覧を表示する（例: `{{ user.id }}`） |

### 3-2. データ保存

| # | 要件 |
|---|------|
| F6 | HTMLブロックはLexical JSONの `html-block` ノードとして `value`（JSON）に保存される。Liquid テンプレートは未レンダリングのまま保存する |
| F7 | 保存時にHTMLをサーバーサイドでサニタイズする（Liquid タグはそのまま保持） |
| F8 | サニタイズにより内容が変化した場合、フロントエンドに `warning` を返す |
| F9 | `warning` を受信したら `window.alert` でユーザーに通知する |

### 3-3. ユーザーサイド表示

| # | 要件 |
|---|------|
| F10 | ユーザーサイドの記事表示で、Liquid テンプレートをレンダリングした上で**実際のHTMLとして**表示する（エスケープしない） |
| F11 | Liquid レンダリング後に必ずサニタイズを通す（二重防御） |
| F12 | Liquid レンダリング時に利用可能な変数: `user`（現在のユーザー情報） |

---

## 4. セキュリティ要件

### 4-1. サニタイズ方針

CMSの管理者は信頼されたユーザーであるため、**最小限のサニタイズ**（スクリプト実行の防止のみ）を行う。
`rails-html-sanitizer`（既存dep）を使用。ブロックリスト方式。

#### 除去するもの

| 種別 | 例 | 理由 |
|------|----|------|
| `<script>` タグ | `<script>alert(1)</script>` | XSS防止 |
| イベントハンドラ属性 | `onclick="..."`, `onsubmit="..."`, `onerror="..."` | XSS防止 |
| `<object>` タグ | `<object data="...">` | レガシー、使用理由がない |
| `<embed>` タグ | `<embed src="...">` | レガシー、使用理由がない |

#### 許可するもの（代表例）

| 種別 | 例 | 理由 |
|------|----|------|
| `<iframe>` タグ | `<iframe src="https://www.youtube.com/...">` | 外部コンテンツ埋め込みはCMSのコアユースケース |
| `style` 属性 | `style="color:red"` | カスタムレイアウト・装飾はCMSとして必要 |
| `<form>` + `<input>` | `<form action="...">` | 外部フォーム埋め込みはコアユースケース |
| その他全タグ・属性 | `<div>`, `<table>`, `class`, `id` 等 | 上記の除去対象以外はすべて許可 |

### 4-2. 保存と表示の二重サニタイズ

```
[保存時] SaveRichtextFieldService → HtmlBlockSanitizer.sanitize → DB保存
[表示時] LexicalHelper#render_node → HtmlBlockSanitizer.sanitize → raw出力
```

---

## 5. データフロー

```
[管理画面]
  HtmlBlockNode（textarea入力 — HTML + Liquid テンプレート）
    ↓ Lexical JSON serialize
  { type: "html-block", html: "<p>{{ user.name }}さん</p>", version: 1 }
    ↓ HiddenFieldSyncPlugin → lexical:change event
  autosave_field_controller.ts
    ↓ PATCH /richtext_fields/:api_identifier  { value: JSON }
  SaveRichtextFieldService#save_field_value
    ↓ HtmlBlockSanitizer.sanitize（Liquid タグは保持、script 等のみ除去）
  ContentEntry::FieldRichtext（DB保存 — Liquid テンプレートのまま）
    ↓ JSON response { success, saved_at, warning? }
  autosave_field_controller.ts
    ↓ warning あり → window.alert("...")

[ユーザーサイト]
  ContentEntry::FieldRichtext#value（JSON）
    ↓ LexicalHelper#lexical_to_html
  html-block node
    ↓ Liquid::Template.parse(html).render({ "user" => current_user_drop })
    ↓ HtmlBlockSanitizer.sanitize
    ↓ .html_safe
    ↓ raw() in view
  実際のHTMLとして表示
```

### 5-2. Liquid 変数スコープ

| 変数 | 内容 | 例 |
|------|------|----|
| `user.id` | ユーザーID | `{{ user.id }}` → `"abc123"` |

> 将来的に `site`, `entry`, `collections` 等の変数を追加する場合は、`LiquidContextBuilder` に変数を追加するだけで拡張可能な設計とする。

### 5-3. Liquid の安全性

Liquid はサンドボックス型のテンプレートエンジンであり、以下の特性を持つ:
- 任意の Ruby コード実行は**不可能**
- ファイルシステムやネットワークへのアクセスは**不可能**
- テンプレート内で利用可能なデータは明示的に渡した変数のみ
- 無限ループ防止のための制限あり（デフォルトで有効）

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

### AC2a: Liquid テンプレートの動的レンダリング
- [ ] `{{ user.id }}` を含むHTMLブロックが保存できる
- [ ] ユーザーサイドで `{{ user.id }}` がログインユーザーの ID に置換される
- [ ] 未ログイン時は `user` 変数が空として扱われる

### AC3: サニタイズ動作
- [ ] `<script>` タグが除去される
- [ ] `onclick` 等のイベントハンドラが除去される
- [ ] サニタイズで内容が変化した場合、保存後にalertが表示される
- [ ] `style` 属性を含むHTMLがそのまま保持される
- [ ] `<iframe>` タグがそのまま保持される
- [ ] 安全なタグ（`<div>`, `<table>`, `<form>` 等）は保持される

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
| `onclick` 属性を含む入力 | `onclick` 属性が除去される |
| `onerror` 属性を含む入力 | `onerror` 属性が除去される |
| `<object>` タグを含む入力 | `object` タグが除去される |
| `<embed>` タグを含む入力 | `embed` タグが除去される |
| `style` 属性を含む入力 | `style` 属性が保持される |
| `<iframe>` タグを含む入力 | `iframe` タグが保持される |
| `<form>` + `<input>` を含む入力 | `form`, `input`, `action`, `type`, `value` が保持される |
| `<table>` タグを含む入力 | `table`, `tr`, `td` が保持される |
| Liquid タグ `{{ user.id }}` を含む入力 | Liquid タグがそのまま保持される（サニタイズで除去されない） |
| 変更あり → `changed?` | `true` を返す |
| 変更なし → `changed?` | `false` を返す |

### 7-1a. Liquid レンダリングテスト一覧

| テストケース | 期待結果 |
|-------------|---------|
| `{{ user.id }}` を含むテンプレート | ユーザー ID に置換される |
| ユーザーが nil の場合 | Liquid タグが空文字に置換される（エラーにならない） |
| 不正な Liquid 構文 | `Liquid::SyntaxError` をキャッチし、テンプレートをそのまま HTML エスケープして出力 |

### 7-2. 統合テスト一覧

| テストケース | 期待結果 |
|-------------|---------|
| richtext保存（html-block・変更なし） | `warning: nil` のJSONが返る |
| richtext保存（html-block・script タグあり） | `script` 除去 + `warning: "html_sanitized"` が返る |
| richtext保存（html-block・style 属性あり） | `style` 保持 + `warning: nil` が返る |
| richtext保存（html-block・Liquid タグあり） | Liquid タグ保持 + `warning: nil` が返る |
| `html-block` ノードを含む Lexical JSON のバリデーション | バリデーション通過 |
| ユーザーサイド表示（Liquid テンプレート + ユーザー） | Liquid が展開された HTML が表示される |

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
4. `<div style="color:red">test</div>` を入力して保存 → 警告なしで保存され、style が保持されることを確認
5. `<iframe src="https://www.youtube.com/embed/xxx"></iframe>` を入力して保存 → 警告なしで保存されることを確認
6. `<script>alert(1)</script>` を入力して保存 → アラートが表示され、script が除去されることを確認
7. `<input type="hidden" name="user_id" value="{{ user.id }}">` を入力して保存 → 警告なしで保存されることを確認
8. ユーザーサイドにログインして表示 → Liquid が展開され、ユーザー ID が埋め込まれていることを確認

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
| `app/services/html_block_liquid_renderer.rb` | 新規 |
| `app/drops/user_drop.rb` | 新規 |
| `app/frontend/components/HtmlBlockNode.tsx` | 新規 |
| `test/services/html_block_sanitizer_test.rb` | 新規 |
| `test/services/html_block_liquid_renderer_test.rb` | 新規 |
| `app/validators/lexical_json_validator.rb` | 修正 |
| `app/helpers/lexical_helper.rb` | 修正 |
| `app/services/admin_area/contents/base_save_field_service.rb` | 修正 |
| `app/services/admin_area/contents/save_richtext_field_service.rb` | 修正 |
| `app/controllers/admin_area/contents/collection/entries/base_field_controller.rb` | 修正 |
| `app/frontend/components/ToolbarPlugin.tsx` | 修正 |
| `app/frontend/components/LexicalEditor.tsx` | 修正 |
| `app/frontend/controllers/autosave_field_controller.ts` | 修正 |
| `Gemfile` | 修正（`liquid` gem 追加） |

---

## 9. 将来的な拡張への設計方針

- `HtmlBlockSanitizer` は独立サービスとして設計 → 将来の `field_type: :html` でも再利用可能
- `HtmlBlockLiquidRenderer` は変数スコープをハッシュで受け取る設計 → 変数追加時はコンテキストを拡張するだけ
- `UserDrop` は `Liquid::Drop` を継承し、公開するプロパティを明示的に制御 → ユーザーの機密情報（password_digest 等）が漏洩しない
- `LexicalHelper` の `html-block` ハンドリングは独立した private メソッドに分離
- per-field設定を追加する場合は `content_type_field_richtexts` に `html_block_enabled` カラムを追加（`FieldSelect#display_format` と同パターン）
