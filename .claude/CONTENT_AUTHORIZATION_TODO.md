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

---

## 残タスク

### 1. マイグレーション適用
- [ ] `ridgepole:apply` でスキーマをDBに反映
- [ ] Sorbet DSL生成（`tapioca dsl`）

### 2. API エンドポイント

#### 認可タグ管理 API
- [ ] `GET /api/content_authorization_tags` - タグ一覧取得
- [ ] `POST /api/content_authorization_tags` - タグ作成
- [ ] `PATCH /api/content_authorization_tags/:id` - タグ更新
- [ ] `DELETE /api/content_authorization_tags/:id` - タグ削除

#### ユーザータグ管理 API
- [ ] `GET /api/users/:user_id/tags` - ユーザーのタグ一覧
- [ ] `POST /api/users/:user_id/tags` - ユーザーにタグ付与
- [ ] `DELETE /api/users/:user_id/tags/:tag_id` - ユーザーからタグ削除

#### コンテンツ認可 API
- [ ] `GET /api/content_entries/:id/versions/:version/authorizations` - バージョンの認可タグ一覧
- [ ] `POST /api/content_entries/:id/versions/:version/authorizations` - バージョンに認可タグ付与
- [ ] `DELETE /api/content_entries/:id/versions/:version/authorizations/:tag_id` - 認可タグ削除

### 3. 認可ロジック実装
- [ ] コンテンツ取得時の認可チェック（ユーザーのタグとコンテンツのタグを比較）
- [ ] 認可チェック用サービスクラス or Concern の作成
- [ ] 認可失敗時のエラーハンドリング（403 Forbidden）

### 4. 外部連携（remote_id）
- [ ] 外部システムからのタグ同期機能（remote_id を使用）
- [ ] 同期用 API または Rake タスク

### 5. テスト
- [ ] モデルテスト（バリデーション、関連）
- [ ] コントローラーテスト（API エンドポイント）
- [ ] 認可ロジックのテスト

### 6. ドキュメント
- [ ] API ドキュメント（OpenAPI/Swagger）
- [ ] 認可フローの説明ドキュメント

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

### 考慮事項
- タグが付与されていないコンテンツの扱い（全員閲覧可能？管理者のみ？）
- 複数バージョン間でのタグ継承（新バージョン作成時に前バージョンのタグをコピー？）
- パフォーマンス（コンテンツ一覧取得時の認可チェック最適化）
