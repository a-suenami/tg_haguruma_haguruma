# TODO リスト

## 進行中

- [ ] Triple と oauth_provider テーブルを比較して差分を分析（必要なら修正）
  - IDP を使った動作確認
- [ ] ユーザー管理: oauth_provider_id を nullable にして認証プロバイダなしでも作成可能に
  - スキーマ変更: `db/schemas/users.schema` で `null: false` を削除
  - User モデル: `belongs_to :oauth_provider, optional: true` に変更
  - コントローラー/ビュー: プロバイダなしの場合の表示対応
- [ ] バリデーションが不適なときは公開できないようにする
- [ ] 多言語化を disable
- [ ] seed リファクタリング

- [ ] 認可に Pundit を使うかどうか検討

- [ ] 「メディアライブラリから選択」が動いてない

- [ ] first published at をもたせて、それの降順にする
- [ ] swagger の　URL が　example.com になってる

- [ ] e2e テスト

- [ ] Cookie は Redis 使う？

- rspec を並列に実行するとエラーになる（とりあえずパラレルテストをコメントアウトした）

- プレビュー機能

## 完了

- [x] Ruler にユーザー管理機能を実装（一覧、認可タグ、トークン作成）
  - UsersController: 一覧・詳細・新規作成・削除
  - UserTagsController: 認可タグの付与・削除
  - SessionTokensController: トークン作成・一覧・無効化
  - 手動作成ユーザー（last_authenticated_at = NULL）のみ削除可能
  - トークン有効期限: 30/60/90/365日から選択可能
  - UID は空欄の場合 UUID 自動生成

- [x] 全公開と認証済みユーザーに公開を分ける（3段階visibility）
  - `is_public` boolean を `visibility` enum に変更
  - 3段階: public（全公開）, authenticated（認証済みユーザーのみ）, restricted（タグ制限）
  - `ContentEntry::Version` モデルに `VISIBILITIES` 定数と enum 追加（`prefix: true`）
  - `ContentEntriesQuery.authorized?` を3段階対応に修正
  - 編集画面でラジオボタン3択のUI実装
  - 関連サービス・コントローラーを全て更新

- [x] 認可タグ管理機能
  - Admin側: 一覧画面（閲覧のみ）、サイドバーに「認可タグ」メニュー追加
  - Ruler側: CRUD機能（一覧・新規・編集・削除）
  - Rulerの「開発・テスト（内部向け）」メニューに配置
  - 外部連携（remote_id）タグは削除不可

- [x] サイドバー調整
  - メディアとカテゴリーページから2段目サイドバー（コンテンツタイプ一覧）を削除
  - `custom-container-no-sidebar` クラスを追加してフル幅レイアウトに変更

- [x] コンテンツタイプ管理画面 (ruler_area) がエラーになる問題を修正
  - `content_models` → `content_types` へ名称統一
  - URL、コントローラー、ビュー、翻訳ファイルを全てリネーム
  - `TenantSettable` concern の include 漏れを修正

- [x] シングルトン/コレクションで公開バージョンがない場合の404エラーを修正
  - show コントローラーで公開バージョンがない場合は edit へリダイレクト
  - コレクション・シングルトン両方で対応

- [x] 「公開中」と「編集中」のタブを左右逆にする
  - 公開中を左、編集中を右に配置変更

- [x] `/` 直下にアクセスがあった場合、ruler なら /ruler に, admin なら /admin にリダイレクト
  - サブドメインベースのルートリダイレクトを追加（ruler.* → /ruler, admin.* → /admin）

- [x] admin管理画面で認可タグの設定をできるようにする
  - ACCESS CONTROL セクションを編集画面に追加
  - 公開チェックボックスで公開/制限を切り替え
  - インクリメンタルサーチUIで認可タグを選択（単一）
  - `SetAuthorizationTagsService` で認可タグと is_public を保存
  - 公開画面では「✅ 公開」または「🔐 制限」+ タグを表示

- [x] API の認証と認可
  - Bearer トークン認証を `Api::V1::ApplicationController` に実装
  - `current_user` メソッドでセッショントークンからユーザーを取得
  - 認可フィルタリングを修正（一覧でも制限コンテンツを非表示に）
  - OpenAPI ドキュメントにセキュリティスキームと認証エンドポイントを追加
  - テスト用のサンプルデータ（ユーザー、トークン、認可タグ）を seed に追加

- [x] コンテンツ一覧 /api/v1/contents で published_at が NULL のコンテンツが返される問題を修正
  - `ContentEntry::Version.published` スコープに `.where.not(published_at: nil)` を追加
  - `status = published` だけでなく `published_at` も必須条件に

- [x] API の動作確認
  - OpenAPI スペックを追加（`swagger/v1/swagger.yaml`）
  - API ドキュメントへのアクセス制限を設定

- [x] MediaAsset のフィールド型の値を公開タブで開くとプレビュー表示
  - `_media_preview.html.erb` パーシャルを新規作成（DRY化）
  - 画像: 16:9アスペクト比でサムネイル表示（60%幅）
  - 動画/音声/ドキュメント: アイコン表示
  - メディアタイプを日本語表示（画像、動画、音声、ドキュメント）
  - ファイル名とタイプバッジを右側に配置

- [x] 左上の CMS を Haguruma に変更
  - `app/views/layouts/admin_area/application.html.slim` のタイトルとロゴ
  - `app/views/admin_area/auth0/login.html.erb` のログインページロゴ

- [x] 下書き (編集中) のみしか存在しない場合、公開タブを disabled にする
  - 編集画面で `@published_version` がない場合に `disabled` クラスを追加
  - CSS でグレーアウト、`pointer-events: none` でクリック無効化
  - collection/singleton 両方で実装済み

- [x] リッチテキストエディタ中で画像や動画挿入
  - ツールバーの Upload ボタンとドラッグ&ドロップに対応
  - MinIO（S3互換）にアップロード後、エディタに挿入
  - セレクションがない場合はドキュメント末尾に挿入するフォールバック追加

- [x] ブラウザのコンソールに以下のようなエラーが出る。
      flushSync was called from inside a lifecycle method. React cannot flush when React is already rendering. Consider moving this call to a scheduler task or micro task. react-dom.development.js:141:21
          flushSync React
          useDecorators LexicalRichTextPlugin.dev.mjs:86
          triggerListeners Lexical.dev.mjs:8407
          $commitPendingUpdates Lexical.dev.mjs:8356
          setEditorState Lexical.dev.mjs:10594
          InitialContentPlugin InitialContentPlugin.tsx:53
  - ✅ 修正完了: `InitialContentPlugin.tsx` で `setEditorState` と `editor.update` を `queueMicrotask` でラップ
  - React のレンダリングサイクル外で Lexical の状態更新を実行するように変更

- [x] Admin の「メディア」の機能がエラー
  - ActiveRecord::StatementInvalid in AdminArea::Media#index
    Showing /rails_app/app/views/admin_area/media/index.html.erb where line #49 raised:
    PG::UndefinedTable: ERROR:  relation "active_storage_attachments" does not exist
  - ✅ 修正完了: Active Storage を削除し、S3/CloudFront 直接管理に統一
    - `MediaAsset` モデルから `has_one_attached :file` を削除
    - ビューで `media.file.attached?` → `media.s3_object_path.present?` に変更
    - コントローラーの `create` を `Uploader` クラス使用に統一

- [x] リッチテキストエディタのフォーマットエラー
  - EditController で JSON 二重エンコードが発生していた
  - `extract_field_value` で `.to_json` を呼ばず Hash をそのまま返すように修正

- [x] **公開中画面でリッチテキストをWYSIWYGとして読み取り専用表示**
  - `LexicalEditor.tsx` に `editable` プロパティを追加（デフォルト `true`）
  - `react_lexical_controller.ts` に `editable` value を追加
  - `_field_display.html.erb` で Lexical エディタを `editable=false` で使用

- [x] 二段目サイドバー下部の重複ナビゲーション確認・削除
  - 「コンテンツタイプ管理」「メディア」「カテゴリー」が一段目と重複しているか確認
  - 重複している場合は削除
  - ✅ 確認済み＆削除完了

- [x] 公開機能が動いてないような気がする
  - singleton/publications_controller.rb の create アクションが未実装だった → PublishEntryService を使用するよう修正
  - edit.html.erb で `button_to` が `form_with` 内にネストされていたため、HTML仕様上無効になっていた
  - `button_to` を `link_to` + `data-turbo-method` に変更して修正完了

- [x] ruler_area の CSS 404 問題を解決
  - Propshaft CSS を Vite SCSS に統合
  - `stylesheet_link_tag` をレイアウトから削除
  - `app/assets/stylesheets/ruler_area/` を削除

- [x] Propshaft を削除して Vite に完全統一
  - Gemfile から `gem 'propshaft'` を削除
  - `app/views/layouts/application.html.erb` を Vite 用に更新
  - ロゴ画像を `public/images/ruler_area/` に移動し、直接パスで参照
  - `config/initializers/assets.rb` から Propshaft 設定を削除
  - `app/assets/stylesheets/` ディレクトリを削除

- [x] ナビゲーションにコンテンツタイプ名が表示されない問題を修正（seed再実行で解決）

- [x] AutoEmbedNode.tsx の重複キー `type` を修正（`embedType`に変更）

- [x] tenant factory の ID を sequence に変更（CI失敗の修正）

- [x] Rulerユーザー登録手順を確認

- [x] Lexical エディタで編集中タブに戻ったとき値が復帰しない問題を修正
  - `InitialContentPlugin.tsx` を新規作成
  - `LexicalEditor.tsx` で `initialContent` を使用してエディタを初期化するよう修正

- [x] 下書きがない場合に公開コンテンツから自動で下書きを作成する機能を追加
  - `CreateDraftFromPublishedService` を新規作成
  - `EditController` で編集画面を開いた際に下書きがなければ公開バージョンを複製
