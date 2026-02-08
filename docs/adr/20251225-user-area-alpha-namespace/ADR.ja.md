# ADR: UserArea alpha ネームスペースの導入

- **日付**: 2025-12-25
- **ステータス**: 確定

## コンテキスト

UserArea において、フルスタック CMS としての画面実装が求められている。

### 理想的な実装

将来的には以下を指定して柔軟に画面を作成できる動的ページシステムを実装したい:

- URL（パスパラメータは `:var` や `${var}` などで指定）
- テンプレート（ERB もしくは Liquid）
- ロードするコンテンツタイプ
  - シングルトンの場合はコンテンツタイプのみ
  - コレクションの場合はフィルター条件

### 短期的な要求

具体的に必要な画面がすでに決まっており、動的ページシステムの完成を待たずに最短で実装したい。ただし、将来的な切り替えが容易な構成にしておく必要がある。

### 設計上の考慮点

1. **URL の安定性**: 短期実装から本実装への切り替え時に URL が変わってはならない
2. **コードの分離**: 短期実装（ハードコード）と本実装を明確に分離したい
3. **共通ロジックの再利用**: 認証・テナント設定などは既存の `UserArea::ApplicationController` を継承して再利用したい

## 決定

**`alpha` ネームスペースを導入し、短期実装を隔離する**。

具体的には:

1. `app/controllers/user_area/alpha/` ディレクトリを作成
2. `UserArea::Alpha::BaseController` を作成し、`UserArea::ApplicationController` を継承
3. ルーティングで `scope module: :alpha` を使用し、URL パスに影響を与えずにコントローラーのみを切り替える

### なぜ v2 ではなく alpha か

- 理想形（動的ページシステム）が「正規」の実装
- 短期的なハードコード実装は「仮」であり、特別扱いすべき
- `v2` は「新しいバージョン」を意味し、正規のパスに置くべき
- `alpha` は「初期・試験的」を意味し、後で削除される前提が明確

## 実装

### ディレクトリ構成

```
app/controllers/user_area/
├── application_controller.rb        # 共通（認証、テナント設定）
├── contents_controller.rb           # 既存
├── alpha/                            # 短期実装
│   ├── base_controller.rb           # < ApplicationController
│   └── pages_controller.rb          # 各画面のアクション
```

### ルーティング

```ruby
# config/routes/user_area.rb
namespace :user_area, path: '' do
  # 既存ルート...

  # alpha: 短期実装（動的ページシステム完成後に削除）
  scope module: :alpha do
    get '/products', to: 'pages#products'
    # 他の画面...
  end
end
```

`scope module: :alpha` は URL パスに影響しない:

| 書き方 | URL | コントローラー |
|--------|-----|---------------|
| `scope module: :alpha` | `/products` | `UserArea::Alpha::PagesController` |
| `namespace :alpha` | `/alpha/products` | `UserArea::Alpha::PagesController` |

### 本実装への移行

動的ページシステム完成後:

```ruby
# Before (alpha)
scope module: :alpha do
  get '/products', to: 'pages#products'
end

# After (本実装)
get '*path', to: 'pages#show', constraints: UserArea::PageConstraint
```

URL は変わらず、コントローラーのみ差し替わる。`alpha/` ディレクトリは削除可能。

## 影響

### Positive

- 短期実装と本実装の境界が明確
- URL は安定し、切り替え時に変更不要
- 認証・テナント設定などの共通ロジックを継承で再利用
- `alpha/` ディレクトリを削除するだけで移行完了

### Negative

- 短期実装期間中は `alpha/` と将来の本実装コードが並存する可能性
- `alpha` という命名が残り続けると意図が曖昧になるため、本実装完了後は速やかに削除すべき
