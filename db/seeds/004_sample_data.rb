# frozen_string_literal: true

# ==============================================================================
# Sample Data for Development/Testing
# ==============================================================================
# Creates sample content types, entries, and authorization tags for testing
# the API authorization functionality.

Rails.logger.debug '📝 Seeding Sample Data...'

Tenant.current_id = 'sample'

# -----------------------------------------------------------------------------
# Content Type: Article (Collection)
# -----------------------------------------------------------------------------
article_type = ContentType.find_or_initialize_by(unique_name: 'article')
article_type.assign_attributes(
  display_name: '記事',
  description: 'ニュースや記事コンテンツ',
  is_collection: true,
)

if article_type.save
  Rails.logger.debug { "  ✅ ContentType: #{article_type.display_name} (#{article_type.unique_name})" }

  # Title field
  title_field = article_type.fields.find_or_initialize_by(api_identifier: 'title')
  title_field.assign_attributes(
    label: 'タイトル',
    field_type: :text,
    required: true,
    position: 0,
  )
  title_field.text ||= ContentType::FieldText.create!
  title_field.save!

  # Body field
  body_field = article_type.fields.find_or_initialize_by(api_identifier: 'body')
  body_field.assign_attributes(
    label: '本文',
    field_type: :text,
    required: false,
    position: 1,
  )
  body_field.text ||= ContentType::FieldText.create!
  body_field.save!

  Rails.logger.debug { "    - Fields: #{article_type.fields.count}" }
else
  Rails.logger.debug { "  ❌ Failed: #{article_type.errors.full_messages.join(', ')}" }
end

# -----------------------------------------------------------------------------
# Authorization Tags
# -----------------------------------------------------------------------------
Rails.logger.debug '🔐 Creating Authorization Tags...'

premium_tag = ContentAuthorizationTag.find_or_create_by!(name: 'premium') do |tag|
  Rails.logger.debug { "  ✅ Tag: #{tag.name}" }
end

member_tag = ContentAuthorizationTag.find_or_create_by!(name: 'member') do |tag|
  Rails.logger.debug { "  ✅ Tag: #{tag.name}" }
end

Rails.logger.debug { "  ✅ Authorization Tags: #{ContentAuthorizationTag.count}" }

# -----------------------------------------------------------------------------
# Content Entries
# -----------------------------------------------------------------------------
Rails.logger.debug '📄 Creating Content Entries...'

# Helper to create a content entry with a published version
def create_article(content_type:, title:, body:, authorization_tags: [])
  entry = ContentEntry.create!(content_type:)

  ContentEntry::Version.create!(
    content_entry_id: entry.id,
    content_type_id: content_type.id,
    version: 1,
    status: :published,
    published_at: Time.current,
    is_public: authorization_tags.empty?,
  )

  # Create field values
  title_field_def = content_type.fields.find_by(api_identifier: 'title')
  body_field_def = content_type.fields.find_by(api_identifier: 'body')

  title_text = ContentEntry::FieldText.create!(value: title)
  ContentEntry::Field.create!(
    content_type_id: content_type.id,
    content_entry_id: entry.id,
    version: 1,
    content_type_field: title_field_def,
    field_type: :text,
    text: title_text,
  )

  body_text = ContentEntry::FieldText.create!(value: body)
  ContentEntry::Field.create!(
    content_type_id: content_type.id,
    content_entry_id: entry.id,
    version: 1,
    content_type_field: body_field_def,
    field_type: :text,
    text: body_text,
  )

  # Add authorization tags
  authorization_tags.each do |tag|
    ContentEntryAuthorization.create!(
      content_entry_id: entry.id,
      version: 1,
      content_authorization_tag: tag,
    )
  end

  entry
end

# Public article (accessible to everyone)
public_article = create_article(
  content_type: article_type,
  title: '公開記事: お知らせ',
  body: 'これは誰でも閲覧できる公開記事です。',
  authorization_tags: [],
)
Rails.logger.debug { "  ✅ Public Article: #{public_article.id}" }

# Member-only article
member_article = create_article(
  content_type: article_type,
  title: '会員限定: 会員様へのお知らせ',
  body: 'これは会員のみ閲覧できる記事です。',
  authorization_tags: [member_tag],
)
Rails.logger.debug { "  ✅ Member Article: #{member_article.id}" }

# Premium-only article
premium_article = create_article(
  content_type: article_type,
  title: 'プレミアム限定: 特別コンテンツ',
  body: 'これはプレミアム会員のみ閲覧できる記事です。',
  authorization_tags: [premium_tag],
)
Rails.logger.debug { "  ✅ Premium Article: #{premium_article.id}" }

Rails.logger.debug { "  📊 Total Entries: #{ContentEntry.count}" }
Rails.logger.debug { "  📊 Total Versions: #{ContentEntry::Version.count}" }
Rails.logger.debug { "  📊 Total Authorizations: #{ContentEntryAuthorization.count}" }

# -----------------------------------------------------------------------------
# OAuth Provider (for test users)
# -----------------------------------------------------------------------------
Rails.logger.debug '🔑 Creating OAuth Provider...'

oauth_provider = OauthProvider.find_or_create_by!(tenant_id: 'sample', kind: 'user') do |p|
  p.client_id = 'test-client-id'
  p.endpoint_base = 'https://id-platform.example.com'
  p.scopes = 'openid profile email'
end
Rails.logger.debug { "  ✅ OauthProvider: #{oauth_provider.id}" }

# -----------------------------------------------------------------------------
# Test Users & Session Tokens
# -----------------------------------------------------------------------------
Rails.logger.debug '👤 Creating Test Users...'

# Public user (no tags - can only access public content)
public_user = User.find_or_create_by!(uid: 'test-public-user', oauth_provider:)
public_token = SessionToken.find_or_create_by!(id: 'test-public-token') do |t|
  t.user = public_user
  t.tenant_id = 'sample'
  t.expires_at = 1.year.from_now
end
Rails.logger.debug { "  ✅ Public User: #{public_user.id}" }
Rails.logger.debug { "    Token: #{public_token.id}" }

# Member user (has 'member' tag)
member_user = User.find_or_create_by!(uid: 'test-member-user', oauth_provider:)
UserTag.find_or_create_by!(user: member_user, content_authorization_tag: member_tag)
member_token = SessionToken.find_or_create_by!(id: 'test-member-token') do |t|
  t.user = member_user
  t.tenant_id = 'sample'
  t.expires_at = 1.year.from_now
end
Rails.logger.debug { "  ✅ Member User: #{member_user.id}" }
Rails.logger.debug { "    Token: #{member_token.id}" }
Rails.logger.debug { '    Tags: [member]' }

# Premium user (has 'premium' tag)
premium_user = User.find_or_create_by!(uid: 'test-premium-user', oauth_provider:)
UserTag.find_or_create_by!(user: premium_user, content_authorization_tag: premium_tag)
premium_token = SessionToken.find_or_create_by!(id: 'test-premium-token') do |t|
  t.user = premium_user
  t.tenant_id = 'sample'
  t.expires_at = 1.year.from_now
end
Rails.logger.debug { "  ✅ Premium User: #{premium_user.id}" }
Rails.logger.debug { "    Token: #{premium_token.id}" }
Rails.logger.debug { '    Tags: [premium]' }

# VIP user (has both 'member' and 'premium' tags)
vip_user = User.find_or_create_by!(uid: 'test-vip-user', oauth_provider:)
UserTag.find_or_create_by!(user: vip_user, content_authorization_tag: member_tag)
UserTag.find_or_create_by!(user: vip_user, content_authorization_tag: premium_tag)
vip_token = SessionToken.find_or_create_by!(id: 'test-vip-token') do |t|
  t.user = vip_user
  t.tenant_id = 'sample'
  t.expires_at = 1.year.from_now
end
Rails.logger.debug { "  ✅ VIP User: #{vip_user.id}" }
Rails.logger.debug { "    Token: #{vip_token.id}" }
Rails.logger.debug { '    Tags: [member, premium]' }

Rails.logger.debug ''
Rails.logger.debug '📋 Test Tokens Summary:'
Rails.logger.debug '   - test-public-token  → Public user (no restricted access)'
Rails.logger.debug '   - test-member-token  → Member user (can access member content)'
Rails.logger.debug '   - test-premium-token → Premium user (can access premium content)'
Rails.logger.debug '   - test-vip-token     → VIP user (can access all content)'
