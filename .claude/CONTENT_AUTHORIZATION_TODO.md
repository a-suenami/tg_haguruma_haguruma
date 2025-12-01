# コンテンツ認可（タグ付け）機能 - 残タスク

## 完了済み

### DB設計
- [x] `content_authorization_tags` テーブル（認可タグマスター）
- [x] `user_tags` テーブル（ユーザー ↔ タグ関連）
- [x] `content_entry_authorizations` テーブル（コンテンツバージョン ↔ タグ関連）

### モデル
- [x] `ContentAuthorizationTag` モデル
- [x] `UserTag` モデル
- [x] `ContentEntryAuthorization` モデル
- [x] `User` への関連追加（`has_many :user_tags`, `has_many :content_authorization_tags`）
- [x] `ContentEntry::Version` への関連追加（`has_many :content_entry_authorizations`, `has_many :content_authorization_tags`）

### マイグレーション適用
- [x] Schemafile にスキーマファイルを追加
- [ ] `ridgepole:apply` でスキーマをDBに反映（Docker環境で実行）
- [ ] Sorbet DSL生成（`tapioca dsl`）（Docker環境で実行）

### API エンドポイント

#### 認可タグ管理 API
- [x] `GET /api/v1/content_authorization_tags` - タグ一覧取得
- [x] `POST /api/v1/content_authorization_tags` - タグ作成
- [x] `PATCH /api/v1/content_authorization_tags/:id` - タグ更新
- [x] `DELETE /api/v1/content_authorization_tags/:id` - タグ削除

#### ユーザータグ管理 API
- [x] `GET /api/v1/users/:user_id/tags` - ユーザーのタグ一覧
- [x] `POST /api/v1/users/:user_id/tags` - ユーザーにタグ付与
- [x] `DELETE /api/v1/users/:user_id/tags/:id` - ユーザーからタグ削除

#### コンテンツ認可 API
- [x] `GET /api/v1/content_entries/:id/versions/:version/authorizations` - バージョンの認可タグ一覧
- [x] `POST /api/v1/content_entries/:id/versions/:version/authorizations` - バージョンに認可タグ付与
- [x] `DELETE /api/v1/content_entries/:id/versions/:version/authorizations/:id` - 認可タグ削除

### 認可ロジック実装
- [x] コンテンツ取得時の認可チェック（ユーザーのタグとコンテンツのタグを比較）
- [x] 認可チェック用サービスクラス（`ContentAuthorizationService`）
- [x] 認可失敗時のエラーハンドリング（403 Forbidden）
- [x] ContentsController への認可チェック組み込み

### テスト
- [x] モデルテスト（バリデーション、関連）
- [x] コントローラーテスト（API エンドポイント）
- [x] 認可ロジックのテスト

---

## 残タスク

### 1. マイグレーション実行（Docker環境で実行）
```bash
source env.sh && bundle exec rails ridgepole:apply
source env.sh && tapioca dsl
```

### 2. 外部連携（remote_id）
- [ ] 外部システムからのタグ同期機能（remote_id を使用）
- [ ] 同期用 API または Rake タスク

### 3. ドキュメント
- [ ] API ドキュメント（OpenAPI/Swagger）
- [ ] 認可フローの説明ドキュメント

### 4. 認証統合
- [ ] API v1 にユーザー認証機能を追加
- [ ] `current_user` メソッドの実装
- [ ] 認可チェックで実際のユーザーを使用

---

## 設計メモ

### 認可の仕組み
```
ユーザー --[user_tags]--> タグA, タグB
コンテンツバージョン --[content_entry_authorizations]--> タグA, タグC

認可チェック:
  ユーザーのタグ ∩ コンテンツのタグ ≠ ∅ → アクセス許可
  （ユーザーがコンテンツに付与されたタグのいずれかを持っていれば閲覧可能）
```

### 実装済みの認可ルール
- **タグなしコンテンツ**: 全員閲覧可能
- **タグありコンテンツ + 未認証ユーザー**: アクセス拒否（403）
- **タグありコンテンツ + 認証ユーザー**: ユーザーがいずれかのタグを持っていればアクセス許可

### 考慮事項（未実装）
- 複数バージョン間でのタグ継承（新バージョン作成時に前バージョンのタグをコピー？）
- パフォーマンス（コンテンツ一覧取得時の認可チェック最適化）

---

## 実装ファイル一覧

### コントローラー
- `app/controllers/api/v1/content_authorization_tags_controller.rb`
- `app/controllers/api/v1/user_tags_controller.rb`
- `app/controllers/api/v1/content_entry_authorizations_controller.rb`

### サービス
- `app/services/content_authorization_service.rb`

### ルーティング
- `config/routes/api.rb`

### テスト
- `spec/models/content_authorization_tag_spec.rb`
- `spec/models/user_tag_spec.rb`
- `spec/models/content_entry_authorization_spec.rb`
- `spec/services/content_authorization_service_spec.rb`
- `spec/requests/api/v1/content_authorization_tags_spec.rb`
- `spec/requests/api/v1/user_tags_spec.rb`
- `spec/requests/api/v1/content_entry_authorizations_spec.rb`

### ファクトリ
- `spec/factories/content_authorization_tags.rb`
- `spec/factories/user_tags.rb`
- `spec/factories/content_entry_authorizations.rb`
