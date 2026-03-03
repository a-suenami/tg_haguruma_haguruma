# ADR: コンテンツエントリの自動保存と公開処理のレース・コンディション修正

- **日付**: 2026-03-04
- **ステータス**: 確定

## コンテキスト

コンテンツエントリの編集画面では、フィールドの変更を自動保存する機能（autosave）が2つのメカニズムで動作している。

- **`autosave_field_controller.ts`**: フィールド単位の自動保存。変更検知後1秒のデバウンス、またはフォーカスアウト時に即時発火。`PATCH /entries/:entry_id/fields/:api_identifier` を呼び `BaseSaveFieldService` が処理する。
- **`autosave_form_controller.ts`**: フォーム全体の自動保存。10秒ごとのインターバル、またはフォーカスアウト時に即時発火。`PATCH /entries/:entry_id` を呼び `SaveEntryService` が処理する。

管理者が公開済みエントリを編集し「保存（下書き保存）」→「公開」と素早く操作した場合、以下のレース・コンディションが発生することが確認された。

```
T1: ユーザーがフィールドを変更（autosave デバウンス開始、まだ発火していない）
T2: ユーザーが「保存」→ SaveEntryService が draft version N+1 を作成
T3: ユーザーが「公開」→ PublishEntryService が draft (status=1) を published (status=3) に変更
T4: autosave のデバウンスが完了し PATCH リクエスト送信
T5: BaseSaveFieldService が find_by(status: :draft) → 見つからない（公開済みのため）
T6: max_version + 1 で新規の空ドラフトを作成
T7: autosave した1フィールドのみが保存される → title・画像・他フィールドが消失
```

根本原因は `BaseSaveFieldService#find_or_create_draft_version` の設計にある。ドラフトが見つからない場合、公開済みバージョンの存在を確認せず、既存フィールドを引き継がない**空のドラフトを新規作成**してしまう。

```ruby
# 問題のあるコード (base_save_field_service.rb)
def find_or_create_draft_version
  existing_draft = ContentEntry::Version.find_by(
    status: ContentEntry::Version::STATUSES[:draft], ...
  )
  return existing_draft if existing_draft

  # 公開後に呼ばれると空ドラフトが作られてしまう
  max_version = ContentEntry::Version.where(...).maximum(:version) || 0
  ContentEntry::Version.new(version: max_version + 1, status: :draft, ...).tap(&:save)
end
```

また、自動保存と公開処理の間に排他制御がなく、並列実行に対して無防備であった。

## 決定

以下の3層の防御策を実装する。

### 修正1: `BaseSaveFieldService` — 自動保存は既存ドラフトの更新のみに限定

`find_or_create_draft_version` をドラフトが存在しない場合に新規作成しないよう変更する。ドラフトが見つからない場合はエラーを返してトランザクションをロールバックする（サイレント失敗）。

```ruby
# 修正後
def find_draft_version_or_fail
  draft = ContentEntry::Version.find_by(status: :draft, ...)
  unless draft
    @errors << '保存対象の下書きが見つかりません'
    raise ActiveRecord::Rollback
  end
  draft
end
```

新規ドラフトの作成は、管理者が手動で「保存」ボタンを押した場合（`SaveEntryService`）のみ許可する。

### 修正2: 悲観的ロック（Pessimistic Lock）の追加

`BaseSaveFieldService` と `PublishEntryService` のトランザクション開始直後に `content_entry.lock!`（PostgreSQL の `SELECT FOR UPDATE`）を追加する。

```ruby
# BaseSaveFieldService#call
ActiveRecord::Base.transaction do
  @content_entry.lock!
  version = find_draft_version_or_fail
  # ...
end

# PublishEntryService#call
ActiveRecord::Base.transaction do
  @content_entry.lock!
  draft_version = find_draft_version
  # ...
end
```

**効果:**
- 公開処理中 → autosave はロック取得まで待機 → 公開完了後にロック取得 → ドラフトなし → 修正1によりサイレント失敗
- autosave 中 → 公開処理はロック取得まで待機 → autosave 完了後に公開実行 → 正常に公開

本修正は PostgreSQL の行レベルロックを前提とする（本番・ステージング環境ともに PostgreSQL を使用していることを確認済み）。

### 修正3: フロントエンド — 「保存」「公開」ボタン押下時に autosave をキャンセル

「保存」「公開」ボタン押下時に `autosave:cancel` カスタムイベントを dispatch し、各 autosave コントローラーがデバウンスタイマーのクリアと進行中の fetch リクエストのキャンセルを行う。

現状の `autosave_field_controller.ts` は `fetch()` に `AbortController` を使用していないため、リクエスト送信後はキャンセル不可能である。`AbortController` を追加して in-flight リクエストもキャンセルできるようにする。

```typescript
// autosave_field_controller.ts
private currentAbortController: AbortController | null = null;

cancelAutosave() {  // autosave:cancel イベントのハンドラ
  this.clearDebounce();
  this.currentAbortController?.abort();
  this.currentAbortController = null;
}

private async save() {
  this.currentAbortController = new AbortController();
  const response = await fetch(this.urlValue, {
    signal: this.currentAbortController.signal,
    // ...
  });
}
```

## 理由

### 修正1を最優先とした理由

- データ消失（フィールドの欠落）を直接引き起こす根本原因への対処
- 「autosave はあくまで補助機能であり、手動操作の直後にサイレント失敗しても許容できる」という UX 方針と一致する
- `SaveEntryService`（手動保存）と `BaseSaveFieldService`（autosave）の責務が明確に分離される

### 修正2を採用した理由

- 修正1と組み合わせることで「autosave が公開後にドラフトを見つけられない」という状態を確実に作り出せる
- 処理順序が保証されるため、修正1のサイレント失敗が正しいタイミングで発生する
- PostgreSQL の `SELECT FOR UPDATE` は本番環境で利用可能であり、導入コストが低い

### 修正3を採用した理由

- レース・コンディションの発生確率を発生源（フロントエンド）で低減する多層防御
- バックエンドの修正（1・2）は「発生した際の被害を防ぐ」、フロントエンドの修正（3）は「そもそも発生させない」という補完的な関係

### 「公開済みから新規ドラフトをコピーする」アプローチを採用しなかった理由

autosave が公開後に published version をコピーして新規ドラフトを作成し、autosave のフィールドを上書きする方法も検討した。しかしこの方法は:

- ユーザーが意図しないタイミングで新規ドラフトが作成される
- autosave のたびに `CreateDraftFromPublishedService` が呼ばれ得る
- 複雑さが増す割に、「公開直後に別フィールドを autosave したい」という正当なユースケースが存在しない

## 影響

- autosave 中に「保存失敗」のステータスが表示される場合がある（公開操作直後）。これは正常な動作である。
- `BaseSaveFieldService` の責務が「autosave 専用（更新のみ）」に明確化される。
- `SaveEntryService` は引き続き新規ドラフト作成・更新の両方を担う（変更なし）。

## 関連

- `app/services/admin_area/contents/base_save_field_service.rb` — 修正対象（メイン）
- `app/services/admin_area/contents/publish_entry_service.rb` — ロック追加対象
- `app/services/admin_area/contents/save_entry_service.rb` — 変更なし（ドラフト作成の責務を維持）
- `app/frontend/controllers/autosave_field_controller.ts` — AbortController 追加対象
- `app/frontend/controllers/autosave_form_controller.ts` — キャンセル対応追加対象
