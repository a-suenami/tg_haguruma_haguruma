module ContentEntry

open base
open tenant

// コンテンツモデルの定義
sig ContentModel {
  id: one UUID,
  tenant: one Tenant
}

// コンテンツモデルフィールドの定義
sig ContentModelField {
  id: one Int,
  content_model: one ContentModel,
  field_type: one FieldType
}

// コンテンツエントリー（Aggregateルート）の定義
sig ContentEntry {
  id: one UUID,
  tenant: one Tenant,
  content_model: one ContentModel,
  created_at: one Timestamp,
  updated_at: one Timestamp,
  deleted_at: lone Timestamp,
  versions: set ContentEntryVersion
}

// コンテンツエントリーバージョンの定義
sig ContentEntryVersion {
  content_entry: one ContentEntry,
  version: one Int,
  status: one Status,
  created_at: one Timestamp,
  updated_at: one Timestamp,
  fields: set ContentEntryField
}

// コンテンツエントリーフィールドの定義
sig ContentEntryField {
  version: one ContentEntryVersion,
  model_field: one ContentModelField,
  text_value: lone ContentEntryFieldText,
  richtext_value: lone ContentEntryFieldRichText,
  media_value: lone ContentEntryFieldMediaAsset
}

// フィールド値の定義
sig ContentEntryFieldText {
  value: one String
}

sig ContentEntryFieldRichText {
  value: one String // JSONBをStringとして表現
}

sig ContentEntryFieldMediaAsset {
  url: one String,
  metadata: one String // JSONBをStringとして表現
}

// 制約の定義

// 1. ContentEntryVersionは必ず対応するContentEntryのversionsに含まれる
fact VersionBelongsToEntry {
  all v: ContentEntryVersion | v in v.content_entry.versions
}

// 2. 同一ContentEntry内でバージョン番号は一意
fact UniqueVersionNumber {
  all e: ContentEntry, v1, v2: e.versions |
    v1 != v2 implies v1.version != v2.version
}

// 3. ContentEntryFieldは必ず対応するContentEntryVersionのfieldsに含まれる
fact FieldBelongsToVersion {
  all f: ContentEntryField | f in f.version.fields
}

// 4. フィールドの型に応じて適切な値が設定される
fact FieldTypeConsistency {
  all f: ContentEntryField |
    (f.model_field.field_type = TextType implies #f.text_value = 1 and #f.richtext_value = 0 and #f.media_value = 0) and
    (f.model_field.field_type = RichTextType implies #f.text_value = 0 and #f.richtext_value = 1 and #f.media_value = 0) and
    (f.model_field.field_type = MediaType implies #f.text_value = 0 and #f.richtext_value = 0 and #f.media_value = 1)
}

// 5. 同一テナント内のコンテンツエントリーのみ参照可能
fact TenantIsolation {
  all e: ContentEntry |
    e.content_model.tenant = e.tenant
}

// 6. 公開状態のバージョンは各ContentEntryに最大1つ
fact AtMostOnePublishedVersion {
  all e: ContentEntry |
    lone v: e.versions | v.status = Published
}

// 8. 各ステータス（Draft、Preview、Published）は最大1つずつ
fact AtMostOnePerStatus {
  all e: ContentEntry |
    (lone v: e.versions | v.status = Draft) and
    (lone v: e.versions | v.status = Preview) and
    (lone v: e.versions | v.status = Published)
}

// 7. 削除されたエントリーのすべてのバージョンは非公開
fact DeletedEntryVersionsUnpublished {
  all e: ContentEntry |
    some e.deleted_at implies all v: e.versions | v.status = Unpublished
}

// コマンドの定義

// CreateContentEntryコマンド
pred CreateContentEntry[e: ContentEntry, t: Tenant, m: ContentModel] {
  // 事前条件
  e.tenant = t
  e.content_model = m
  no e.deleted_at
  
  // 初期バージョンの作成
  one v: e.versions | {
    v.version = 1
    v.status = Draft
  }
}

// EditContentEntryコマンド（内容変更・編集）
pred EditContentEntry[e: ContentEntry, v_new: ContentEntryVersion] {
  // 事前条件
  no e.deleted_at
  v_new in e.versions
  // 公開中のバージョンが存在する
  some v: e.versions | v.status = Published
  
  // 新バージョンの番号は既存の最大値より1大きい
  v_new.version = max[e.versions.version] + 1
  v_new.status = Draft
}

// PublishContentEntryコマンド
pred PublishContentEntry[e: ContentEntry, v: ContentEntryVersion, e': ContentEntry] {
  // 事前条件
  v in e.versions
  v.status in (Draft + Preview)
  no e.deleted_at
  
  // 事後条件
  e'.id = e.id
  e'.tenant = e.tenant
  e'.content_model = e.content_model
  
  // 他の公開バージョンを非公開にする
  all other: e.versions - v |
    other.status = Published implies
      (some other': e'.versions | 
        other'.version = other.version and 
        other'.status = Unpublished)
  
  // 指定バージョンを公開にする
  some v': e'.versions | 
    v'.version = v.version and 
    v'.status = Published
}

// アサーションの定義

// 公開バージョンの一意性を確認
assert PublishedVersionUniqueness {
  all e: ContentEntry |
    #{ v: e.versions | v.status = Published } <= 1
}

// PreviewContentEntryコマンド
pred PreviewContentEntry[e: ContentEntry, v: ContentEntryVersion, e': ContentEntry] {
  // 事前条件
  v in e.versions
  v.status = Draft
  no e.deleted_at
  
  // 事後条件
  e'.id = e.id
  e'.tenant = e.tenant
  e'.content_model = e.content_model
  
  // 指定バージョンをプレビューにする
  some v': e'.versions | 
    v'.version = v.version and 
    v'.status = Preview
}

// UnpublishContentEntryコマンド（非公開化）
pred UnpublishContentEntry[e: ContentEntry, v: ContentEntryVersion, e': ContentEntry] {
  // 事前条件
  v in e.versions
  v.status = Published
  no e.deleted_at
  
  // 事後条件
  e'.id = e.id
  e'.tenant = e.tenant
  e'.content_model = e.content_model
  
  // 指定バージョンを非公開にする
  some v': e'.versions | 
    v'.version = v.version and 
    v'.status = Unpublished
}

// ArchiveContentEntryコマンド（アーカイブ・削除）
pred ArchiveContentEntry[e: ContentEntry, e': ContentEntry] {
  // 事前条件
  no e.deleted_at
  
  // 事後条件
  e'.id = e.id
  e'.tenant = e.tenant
  e'.content_model = e.content_model
  some e'.deleted_at
  
  // すべてのバージョンを非公開にする
  all v': e'.versions | v'.status = Unpublished
}

// コマンドの実行例
run CreateContentEntry for 5
run EditContentEntry for 5
run PublishContentEntry for 5
run PreviewContentEntry for 5
run UnpublishContentEntry for 5
run ArchiveContentEntry for 5

// 各ステータスの一意性を確認
assert StatusUniqueness {
  all e: ContentEntry |
    (#{ v: e.versions | v.status = Draft } <= 1) and
    (#{ v: e.versions | v.status = Preview } <= 1) and
    (#{ v: e.versions | v.status = Published } <= 1)
}

// テナント分離の確認
assert TenantSeparation {
  all e: ContentEntry |
    e.content_model.tenant = e.tenant
}

// 削除済みエントリーの確認
assert DeletedEntryConsistency {
  all e: ContentEntry |
    some e.deleted_at implies all v: e.versions | v.status = Unpublished
}

// アサーションの検証
check PublishedVersionUniqueness for 10
check StatusUniqueness for 10
check TenantSeparation for 10
check DeletedEntryConsistency for 10

// コマンドの実行
run CreateContentEntry for 5
run EditContentEntry for 5
run PublishContentEntry for 5
run PreviewContentEntry for 5
run UnpublishContentEntry for 5
run ArchiveContentEntry for 5
check StatusUniqueness for 10
check TenantSeparation for 10
check DeletedEntryConsistency for 10