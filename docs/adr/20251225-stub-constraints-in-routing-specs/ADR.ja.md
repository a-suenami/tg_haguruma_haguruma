# ADR: ルーティングスペックでドメイン制約をスタブする

- **日付**: 2025-12-25
- **ステータス**: 確定

## コンテキスト

本システムでは、複数のドメインに対して異なるルートを提供するために、`routes.rb` でドメイン制約（constraints）を使用している。

```ruby
constraints Constraints::AdminDomainConstraint.new do
  draw :admin
end
```

しかし、RSpec の `route_to` マッチャーはカスタム制約オブジェクトを正しく評価しないという既知の問題がある。

### 問題の詳細

RSpec の `route_to` マッチャーは Rails の `assert_recognizes` のラッパーである。`assert_recognizes` は制約オブジェクトの `matches?` メソッドに完全なリクエストオブジェクトを渡さないため、ドメインベースの制約が正しく評価されない。

この問題は RSpec Rails プロジェクトで長年にわたり報告されている:

- [rspec/rspec-rails#1699](https://github.com/rspec/rspec-rails/issues/1699) - `route_to` spec が制約を認識しない
- [rspec/rspec-rails#239](https://github.com/rspec/rspec-rails/issues/239) - ルートの制約が RSpec で認識されない
- [rspec/rspec-rails#712](https://github.com/rspec/rspec-rails/issues/712) - `route_to` マッチャーが制約インスタンスにクエリパラメータを渡さない
- [rails/rails#2781](https://github.com/rails/rails/issues/2781) - 制約マッチャークラスがテスト中に適切なリクエストオブジェクトを受け取らない

結果として、以下のようなルーティングスペックが失敗する:

```ruby
expect(get: '/admin/contents').to route_to(
  controller: 'admin_area/contents/root',
  action: 'index',
)
# => No route matches "/admin/contents"
```

## 決定

ルーティングスペックで `allow_any_instance_of` を使用してドメイン制約をスタブする。

```ruby
RSpec.describe 'AdminArea::Contents routing' do
  before do
    allow_any_instance_of(Constraints::AdminDomainConstraint).to receive(:matches?).and_return(true)
  end

  # ...
end
```

### 検討した選択肢

#### 1. routes.rb でテスト環境の条件分岐

```ruby
if Rails.env.test?
  draw :admin
else
  constraints Constraints::AdminDomainConstraint.new do
    draw :admin
  end
end
```

**不採用理由**: routes.rb にテスト都合の冗長な記述を持ち込むべきではない。本番コードをテストの都合で複雑化させることは保守性を損なう。

#### 2. ルーティングスペックを削除

ドメイン制約付きルートはこの方法でテストできないため、ルーティングスペック自体を削除する。

**不採用理由**: URL（パス）とそのルーティング先である controller と action だけを設計し、実際の処理はその後で書くという実装プロセスは一般的である。例えば、静的であってもまずはレスポンスのフォーマットだけを決めてフロントエンドに返すスタブエンドポイントを実装するケースがある。このような場合に request spec ではなく routing spec を記述したいため、routing spec の削除は妥当ではない。

#### 3. リクエストスペックに変更

実際の HTTP リクエストを使うリクエストスペックでテストする。

**不採用理由**: 選択肢 2 と同様の理由で、routing spec を使用したい場面がある。また、リクエストスペックはコントローラの実装が必要であり、ルーティングのみを先行してテストすることができない。

#### 4. ルーティングスペック内で制約をモック（採用）

`allow_any_instance_of` を使用して制約の `matches?` メソッドをスタブする。

**採用理由**: 制約のスタブはテストコード内に閉じており、本番コードに影響を与えない。ルーティングスペックの本来の目的（URL とコントローラ/アクションのマッピング確認）を達成できる。

## 影響

### Positive

- ルーティングスペックを維持できる
- 本番コード（routes.rb、制約クラス）に変更が不要
- テストの意図が明確（制約をスタブしていることがスペック内で分かる）
- URL 設計を先行してテストする開発フローを維持できる

### Negative

- `allow_any_instance_of` は RSpec のベストプラクティスとしては推奨されない手法である
  - ただし、この場合は制約オブジェクトがルーティング内部で生成されるため、他の方法でモックすることが困難
- ドメイン制約自体の動作は routing spec ではテストされない
  - 必要であれば制約クラスの単体テストを別途作成する
