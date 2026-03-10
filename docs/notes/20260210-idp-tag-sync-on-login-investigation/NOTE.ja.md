# IDP タグ同期（ログイン時）の調査ノート

## 背景

auth-platform の ID トークンに `tags` を含め、Haguruma 側でログイン時にタグを同期する機能をリリースした。
しかし staging 環境でテストしたところ、認可タグが Haguruma に同期されなかった。

## 構成

### auth-platform 側

- ID トークンの `user` claim に `integration_enabled_tags` を追加
- `doorkeeper_openid_connect.rb` の `claim :user` ブロック内で無条件に `json[:tags]` を設定

```ruby
claim :user, response: :id_token do |resource_owner, scope|
  json = {}
  # ... scope 依存のフィールド ...
  json[:tags] = resource_owner.integration_enabled_tags.map do |tag|
    { id: tag.id, name: tag.name }
  end
  json
end
```

### haguruma 側

- ログインコールバック時に `Users::SyncIdpTagsService` を呼び出し
- ID トークンの `user.tags` からタグを取得し、`ContentAuthorizationTag` と `UserTag` を作成

```ruby
# sessions_controller.rb
idp_tags = payload.dig('user', 'tags') || []
Users::SyncIdpTagsService.new(user:, tags: idp_tags).execute if idp_tags.present?
```

## 調査結果

### 症状

- ログインは成功（302 リダイレクト、例外なし）
- `ContentAuthorizationTag` が DB に作成されていない
- haguruma の Rails console から `SyncIdpTagsService` を手動実行すると正常に動作

### 原因: doorkeeper-openid_connect の scope 解決ロジック

haguruma の `OauthProvider.scopes` が `openid` のみに設定されていたため、ID トークンに `user` claim 自体が含まれていなかった。

#### 詳細

doorkeeper-openid_connect (1.8.7) の `Claim` クラスは、scope が明示的に指定されていない場合にデフォルトの scope を自動付与する:

```ruby
# doorkeeper-openid_connect lib/doorkeeper/openid_connect/claims/claim.rb
def initialize(options = {})
  @scope = options[:scope].to_sym if options[:scope]

  # Standard Claims (profile, email, address, phone) に含まれるかチェック
  @scope ||= STANDARD_CLAIMS.find do |_scope, claims|
    claims.include? @name
  end.try(:first)

  # フォールバック: profile スコープをデフォルトにする
  @scope ||= :profile
end
```

そして `ClaimsBuilder.generate` で claim の出力判定を行う:

```ruby
# doorkeeper-openid_connect lib/doorkeeper/openid_connect/claims_builder.rb
def self.generate(access_token, response)
  Doorkeeper::OpenidConnect.configuration.claims.to_h.map do |name, claim|
    if access_token.scopes.exists?(claim.scope) && claim.response.include?(response)
      [name, claim.generator.call(resource_owner, access_token.scopes, access_token)]
    end
  end.compact.to_h
end
```

`claim :user` は scope を指定していないため:

1. `STANDARD_CLAIMS` に `:user` は含まれない → `nil`
2. フォールバックで **`:profile` スコープがデフォルト設定される**
3. `access_token.scopes.exists?(:profile)` が `false` → **`user` claim が丸ごと省略される**

結果、`payload.dig('user', 'tags')` は `nil` となり、`SyncIdpTagsService` が呼ばれなかった。

### 解決策

haguruma の `OauthProvider.scopes` に `profile` を追加する。最低限必要なスコープ:

```
openid profile
```

全フィールドを取得する場合:

```
openid uid email name profile phone_number contact delivery_address
```

## 補足

- `normal_claim` と `claim` は doorkeeper-openid_connect 1.8.7 では `alias` であり同一メソッド
- `claim :user` に明示的に `scope: nil` を渡しても、フォールバックで `:profile` が設定される
- auth-platform 側で `user` claim を scope 非依存にしたい場合は、`Claim` のデフォルト scope 挙動に注意が必要。`tenant_id` は `normal_claim :tenant_id` で定義されているが、名前が OIDC Standard Claims に含まれないためやはり `:profile` がデフォルトになる。ただし `tenant_id` が出力されるのは、haguruma が `profile` スコープを要求していたからに過ぎない

## 関連

- auth-platform ブランチ: `feature/id-token-include-tags`
- haguruma タグ同期 MR: https://git.l.twogate.net/haguruma/haguruma/-/merge_requests/213
- haguruma デバッグログ MR: https://git.l.twogate.net/haguruma/haguruma/-/merge_requests/218
