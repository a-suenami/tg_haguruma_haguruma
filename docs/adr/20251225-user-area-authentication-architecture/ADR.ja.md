# User Area認証アーキテクチャ

## Status

Accepted

## Context

User AreaはOAuthベースの認証を必要とする。マルチテナントシステムであり、各テナントは独自のIdP（Identity Provider）を持つ。

認証フローの実装方法として、以下の2つのアプローチがある:

### 1. OmniAuth を使用する方法

OmniAuthはRack middlewareであり、OAuthプロバイダとの通信を抽象化する。認可コード→トークン交換を自動で行い、結果を `request.env['omniauth.auth']` に格納する。

**利点:**
- 設定が簡潔
- 多くのOAuthプロバイダをサポート
- コールバック処理が簡単

**欠点:**
- Rack middlewareとして動作するため、ルーティング設定が必要
- マルチテナントで動的にプロバイダを変更するには追加の設定が必要
- API認証との実装パターンが異なる

### 2. 手動トークン交換を使用する方法

認可コードを受け取り、サービスクラスでHTTPリクエストを使ってトークンエンドポイントにアクセスする。

**利点:**
- API認証と同じパターン（実装の一貫性）
- マルチテナントでの動的なIdP切り替えが自然
- 既存サービス（`VerifyIdTokenService`）を再利用可能

**欠点:**
- トークン交換ロジックを自前で実装する必要がある

## Decision

**手動トークン交換を使用する方法**を採用する。

理由:
1. **API との実装一貫性**: 既存のAPI認証は手動トークン交換を使用しており、User Areaも同じパターンにすることで保守性が向上する
2. **マルチテナント対応**: 各テナントのIdP情報をデータベースから取得し、動的にトークン交換を行う設計が自然
3. **既存インフラの再利用**: `Auth::IdPlatform::VerifyIdTokenService` および `AuthApi::IdPlatform` を再利用できる

## Implementation

新しいサービス `Auth::IdPlatform::ExchangeCodeService` を作成し、以下のフローを実装する:

1. `SessionsController#create`: OAuth認可URLにリダイレクト（stateパラメータ付き）
2. IdPでユーザーが認証
3. `SessionsController#callback`: 認可コードを受け取る
4. `ExchangeCodeService`: 認可コードをトークンに交換
5. `VerifyIdTokenService`: IDトークンを検証
6. ユーザーを取得/作成し、セッションを確立

## Consequences

### Positive

- API と User Area で認証パターンが統一される
- 既存の `VerifyIdTokenService` をそのまま再利用できる
- マルチテナントでの動的IdP切り替えが自然に実装できる
- OmniAuthの設定・依存が不要

### Negative

- トークン交換ロジックを自前で実装・保守する必要がある
- OmniAuthが提供する追加機能（プロバイダごとの細かな差異の吸収など）は利用できない
