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

## 決定

### 修正1（今回の対応）: `BaseSaveFieldService` — 自動保存は既存ドラフトの更新のみに限定

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

### 今後の方針: 「保存」ボタンの廃止

autosave がすべての変更を自動的に保存しているため、「保存」ボタンは冗長であり、本バグのレース・コンディションを引き起こすトリガーにもなっている。長期的には「保存」ボタンを UI から削除する予定である。削除後は本バグのシナリオ（T2 の手動保存操作）自体が発生しなくなる。

## 理由

### 修正1のみを採用した理由

- 修正1によりデータ消失（空ドラフトの作成）は完全に防止できる
- 「保存」ボタンを将来的に廃止する方針のため、追加の防御策（悲観的ロック、フロントエンドキャンセル）に投資する必要がない
- autosave 専用サービスとして責務を明確化することは、ボタン廃止後の設計にも合致する

### 悲観的ロックを採用しなかった理由

修正1によりデータ消失は防止できるため、現時点では過剰な対応となる。また「保存」ボタン廃止後はレース・コンディション自体が発生しなくなる。

### フロントエンドでの autosave キャンセルを採用しなかった理由

同上。「保存」ボタン廃止により根本的に解消される予定のため、実装コストに見合わない。

### 「公開済みから新規ドラフトをコピーする」アプローチを採用しなかった理由

autosave が公開後に published version をコピーして新規ドラフトを作成し、autosave のフィールドを上書きする方法も検討した。しかしこの方法は:

- ユーザーが意図しないタイミングで新規ドラフトが作成される
- autosave のたびに `CreateDraftFromPublishedService` が呼ばれ得る
- 複雑さが増す割に、「公開直後に別フィールドを autosave したい」という正当なユースケースが存在しない

## 影響

- autosave 中に「保存失敗」のステータスが表示される場合がある（公開操作直後）。これは正常な動作である。
- `BaseSaveFieldService` の責務が「autosave 専用（更新のみ）」に明確化される。
- `SaveEntryService` は引き続き新規ドラフト作成・更新の両方を担う（変更なし）。
- 今後「保存」ボタンを廃止する際は、`SaveEntryService` の新規ドラフト作成ロジックの見直しも伴う。

## 関連

- `app/services/admin_area/contents/base_save_field_service.rb` — 修正対象
- `app/services/admin_area/contents/save_entry_service.rb` — 変更なし（「保存」ボタン廃止時に見直し予定）
