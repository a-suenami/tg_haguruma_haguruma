# ADR: spec/requests 以下で RSpec/VariableName を無効化する

- **日付**: 2025-12-22
- **ステータス**: 確定

## コンテキスト

rswag を使用した OpenAPI スペックのテストでは、HTTP ヘッダーを設定するために `let(:Authorization)` のようにヘッダー名をそのまま変数名として使用する必要がある。

```ruby
let(:Authorization) { "Bearer #{session_token.id}" }
```

しかし、RuboCop の `RSpec/VariableName` ルールは変数名に snake_case を要求するため、`Authorization` のような PascalCase の変数名は警告対象となる。

rswag の仕様上、ヘッダー名と let の変数名は一致している必要があり、snake_case に変更するとテストが動作しなくなる。

## 決定

`.rubocop.yml` で `spec/requests/**/*` に対して `RSpec/VariableName` ルールを無効化する。

```yaml
RSpec/VariableName:
  Exclude:
    - 'spec/requests/**/*'
```

## 影響

### Positive

- rswag のテストで HTTP ヘッダーを自然に設定できる
- 個別のファイルや行で `rubocop:disable` コメントを書く必要がない
- 一貫したルール適用により、新しい request spec を書く際に迷わない

### Negative

- `spec/requests` 以下では snake_case 以外の変数名も許容されるため、意図しない命名が混入する可能性がある
  - ただし、実際に PascalCase を使うのは HTTP ヘッダー名のみであり、影響は限定的
