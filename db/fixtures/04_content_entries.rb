# typed: false
# frozen_string_literal: true

# Set current tenant for default_scope
Tenant.current_id = 'dev-tenant'

# Helper method to create content entry with version and fields
def create_content_entry(content_type_id, fields_data, status: :draft)
  # Create ContentEntry
  entry = ContentEntry.create!(
    tenant_id: 'dev-tenant',
    content_type_id: content_type_id
  )

  # Create Version
  version = ContentEntry::Version.create!(
    tenant_id: 'dev-tenant',
    content_type_id: content_type_id,
    content_entry_id: entry.id,
    version: 1,
    status: ContentEntry::Version::STATUSES[status]
  )

  # Create Fields
  fields_data.each do |api_identifier, value|
    content_type_field = ContentType::Field.find_by!(
      tenant_id: 'dev-tenant',
      content_type_id: content_type_id,
      api_identifier: api_identifier
    )

    case content_type_field.field_type
    when 'text'
      field_value = ContentEntry::FieldText.create!(value: value)
      ContentEntry::Field.create!(
        tenant_id: 'dev-tenant',
        content_type_id: content_type_id,
        content_entry_id: entry.id,
        version: 1,
        content_type_field_id: content_type_field.id,
        field_type: ContentEntry::Field::FIELD_TYPES[:text],
        text_id: field_value.id
      )
    when 'richtext'
      field_value = ContentEntry::FieldRichtext.create!(value: value)
      ContentEntry::Field.create!(
        tenant_id: 'dev-tenant',
        content_type_id: content_type_id,
        content_entry_id: entry.id,
        version: 1,
        content_type_field_id: content_type_field.id,
        field_type: ContentEntry::Field::FIELD_TYPES[:richtext],
        richtext_id: field_value.id
      )
    end
  end

  entry
end

# 記事（article）のエントリー
create_content_entry('00000000-0000-0000-0000-000000000001', {
  'title' => 'Ruby on Railsの最新トレンド2025',
  'body' => { 'type' => 'doc', 'content' => [{ 'type' => 'paragraph', 'content' => [{ 'type' => 'text', 'text' => 'Rails 8.0の新機能について解説します。' }] }] }
}, status: :published)

create_content_entry('00000000-0000-0000-0000-000000000001', {
  'title' => 'データベース設計のベストプラクティス',
  'body' => { 'type' => 'doc', 'content' => [{ 'type' => 'paragraph', 'content' => [{ 'type' => 'text', 'text' => '効率的なデータベース設計のポイントをまとめました。' }] }] }
}, status: :draft)

create_content_entry('00000000-0000-0000-0000-000000000001', {
  'title' => 'マイクロサービスアーキテクチャ入門',
  'body' => { 'type' => 'doc', 'content' => [{ 'type' => 'paragraph', 'content' => [{ 'type' => 'text', 'text' => 'マイクロサービスの基本概念と実装方法を紹介します。' }] }] }
}, status: :published)

create_content_entry('00000000-0000-0000-0000-000000000001', {
  'title' => 'テスト駆動開発（TDD）の実践',
  'body' => { 'type' => 'doc', 'content' => [{ 'type' => 'paragraph', 'content' => [{ 'type' => 'text', 'text' => 'TDDの基本から実践的なテクニックまで解説します。' }] }] }
}, status: :draft)

# お知らせ（announcement）のエントリー
create_content_entry('00000000-0000-0000-0000-000000000002', {
  'title' => 'システムメンテナンスのお知らせ',
  'body' => { 'type' => 'doc', 'content' => [{ 'type' => 'paragraph', 'content' => [{ 'type' => 'text', 'text' => '2025年1月15日（水）午前2時から4時までシステムメンテナンスを実施します。' }] }] }
}, status: :published)

create_content_entry('00000000-0000-0000-0000-000000000002', {
  'title' => '新機能リリースのご案内',
  'body' => { 'type' => 'doc', 'content' => [{ 'type' => 'paragraph', 'content' => [{ 'type' => 'text', 'text' => '新しい機能がリリースされました。詳細はこちらをご覧ください。' }] }] }
}, status: :published)

create_content_entry('00000000-0000-0000-0000-000000000002', {
  'title' => 'セキュリティアップデートの実施',
  'body' => { 'type' => 'doc', 'content' => [{ 'type' => 'paragraph', 'content' => [{ 'type' => 'text', 'text' => 'セキュリティ向上のためのアップデートを実施しました。' }] }] }
}, status: :published)

# 動画（video）のエントリー - MediaAssetは実際のファイルが必要なため、タイトルのみ作成
# 実際の運用ではMediaAssetの作成が必要ですが、ここではスキップします
ContentEntry.create!(
  tenant_id: 'dev-tenant',
  content_type_id: '00000000-0000-0000-0000-000000000003'
)

ContentEntry.create!(
  tenant_id: 'dev-tenant',
  content_type_id: '00000000-0000-0000-0000-000000000003'
)

ContentEntry.create!(
  tenant_id: 'dev-tenant',
  content_type_id: '00000000-0000-0000-0000-000000000003'
)

# 利用規約（terms）のエントリー - singleton
create_content_entry('00000000-0000-0000-0000-000000000010', {
  'body' => { 'type' => 'doc', 'content' => [
    { 'type' => 'heading', 'attrs' => { 'level' => 1 }, 'content' => [{ 'type' => 'text', 'text' => '利用規約' }] },
    { 'type' => 'paragraph', 'content' => [{ 'type' => 'text', 'text' => '本利用規約は、当サービスの利用条件を定めるものです。' }] },
    { 'type' => 'heading', 'attrs' => { 'level' => 2 }, 'content' => [{ 'type' => 'text', 'text' => '第1条（適用）' }] },
    { 'type' => 'paragraph', 'content' => [{ 'type' => 'text', 'text' => '本規約は、本サービスの提供条件及び本サービスの利用に関する当社とユーザーとの間の権利義務関係を定めることを目的とし、ユーザーと当社との間の本サービスの利用に関わる一切の関係に適用されます。' }] }
  ] }
}, status: :published)

# プライバシーポリシー（privacy）のエントリー - singleton
create_content_entry('00000000-0000-0000-0000-000000000011', {
  'body' => { 'type' => 'doc', 'content' => [
    { 'type' => 'heading', 'attrs' => { 'level' => 1 }, 'content' => [{ 'type' => 'text', 'text' => 'プライバシーポリシー' }] },
    { 'type' => 'paragraph', 'content' => [{ 'type' => 'text', 'text' => '当社は、ユーザーの個人情報保護の重要性について認識し、個人情報の保護に関する法律を遵守すると共に、以下のプライバシーポリシーに従って、個人情報を適切に取り扱います。' }] },
    { 'type' => 'heading', 'attrs' => { 'level' => 2 }, 'content' => [{ 'type' => 'text', 'text' => '1. 個人情報の収集' }] },
    { 'type' => 'paragraph', 'content' => [{ 'type' => 'text', 'text' => '当社は、サービス提供のために必要な範囲で個人情報を収集します。' }] }
  ] }
}, status: :published)
