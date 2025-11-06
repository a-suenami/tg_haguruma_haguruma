# typed: false
# frozen_string_literal: true

# Set current tenant for default_scope
Tenant.current_id = 'dev-tenant'

# Collection types
ContentType.seed(:id) do |t|
  t.id = '00000000-0000-0000-0000-000000000001'
  t.tenant_id = 'dev-tenant'
  t.is_collection = true
  t.unique_name = 'article'
  t.display_name = '記事'
  t.description = 'ブログ記事やニュースなどのコンテンツ'
end

ContentType.seed(:id) do |t|
  t.id = '00000000-0000-0000-0000-000000000002'
  t.tenant_id = 'dev-tenant'
  t.is_collection = true
  t.unique_name = 'announcement'
  t.display_name = 'お知らせ'
  t.description = '重要なお知らせや通知'
end

ContentType.seed(:id) do |t|
  t.id = '00000000-0000-0000-0000-000000000003'
  t.tenant_id = 'dev-tenant'
  t.is_collection = true
  t.unique_name = 'video'
  t.display_name = '動画'
  t.description = '動画コンテンツ'
end

# Singleton types
ContentType.seed(:id) do |t|
  t.id = '00000000-0000-0000-0000-000000000010'
  t.tenant_id = 'dev-tenant'
  t.is_collection = false
  t.unique_name = 'terms'
  t.display_name = '利用規約'
  t.description = 'サービス利用規約'
end

ContentType.seed(:id) do |t|
  t.id = '00000000-0000-0000-0000-000000000011'
  t.tenant_id = 'dev-tenant'
  t.is_collection = false
  t.unique_name = 'privacy'
  t.display_name = 'プライバシーポリシー'
  t.description = '個人情報保護方針'
end
