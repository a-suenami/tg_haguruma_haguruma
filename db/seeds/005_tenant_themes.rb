# frozen_string_literal: true

# ==============================================================================
# Tenant Themes and Site Settings
# ==============================================================================

Rails.logger.debug '🎨 Seeding Tenant Themes and Site Settings...'

# -----------------------------------------------------------------------------
# Sample Tenant (default pink theme - きゃりーぱみゅぱみゅ style)
# -----------------------------------------------------------------------------
sample_tenant = Tenant.find_by(id: 'sample')

if sample_tenant
  # Theme (pink-based design)
  theme = TenantTheme.find_or_initialize_by(tenant_id: sample_tenant.id)
  theme.assign_attributes(
    color_primary: '#F2719D',
    color_primary_dark: '#D4567D',
    color_secondary: nil,
    color_on_primary: '#FFFFFF',
    color_background: '#FFFFFF',
    color_surface: '#F5F5F5',
    color_text_primary: '#333333',
    color_text_secondary: '#666666',
    color_outline: '#E0E0E0',
    font_heading: 'Tsukimi Rounded',
    font_primary: 'Zen Maru Gothic',
  )

  if theme.save
    Rails.logger.debug { "  ✅ TenantTheme: #{sample_tenant.name}" }
  else
    Rails.logger.debug { "  ❌ Failed: #{theme.errors.full_messages.join(', ')}" }
  end

  # Site Settings (default English labels)
  site_settings = TenantSiteSettings.find_or_initialize_by(tenant_id: sample_tenant.id)
  site_settings.assign_attributes(
    features: {
      'news' => { 'enabled' => true, 'label' => 'NEWS', 'menu_label' => 'NEWS' },
      'ticket' => { 'enabled' => true, 'label' => 'TICKET', 'menu_label' => 'TICKET' },
      'blog' => { 'enabled' => true, 'label' => 'BLOG', 'menu_label' => 'BLOG' },
      'schedule' => { 'enabled' => true, 'label' => 'SCHEDULE', 'menu_label' => 'SCHEDULE' },
      'profile' => { 'enabled' => false },
    },
    landing: {
      'sections_order' => %w[auth news blog],
    },
    login_label: 'ログイン',
    signup_label: '新規会員登録',
  )

  if site_settings.save
    Rails.logger.debug { "  ✅ TenantSiteSettings: #{sample_tenant.name}" }
  else
    Rails.logger.debug { "  ❌ Failed: #{site_settings.errors.full_messages.join(', ')}" }
  end
end

# -----------------------------------------------------------------------------
# Example: 斧琴菊 (Yokotogiku) style tenant
# Uncomment and adjust when ready
# -----------------------------------------------------------------------------
# yokotogiku_tenant = Tenant.find_by(id: 'yokotogiku')
#
# if yokotogiku_tenant
#   # Theme (blue/yellow based design)
#   theme = TenantTheme.find_or_initialize_by(tenant_id: yokotogiku_tenant.id)
#   theme.assign_attributes(
#     color_primary: '#1B4B7A',      # 紺色
#     color_primary_dark: '#0F3254',
#     color_secondary: '#C9A227',    # 金色/黄色
#     color_on_primary: '#FFFFFF',
#     color_background: '#FFFFFF',
#     color_surface: '#F8F8F8',
#     color_text_primary: '#333333',
#     color_text_secondary: '#666666',
#     color_outline: '#E0E0E0',
#     font_heading: 'Tsukimi Rounded',
#     font_primary: 'Zen Maru Gothic',
#   )
#   theme.save!
#
#   # Site Settings (Japanese labels)
#   site_settings = TenantSiteSettings.find_or_initialize_by(tenant_id: yokotogiku_tenant.id)
#   site_settings.assign_attributes(
#     features: {
#       'news' => { 'enabled' => true, 'label' => 'お知らせ', 'menu_label' => 'お知らせ' },
#       'ticket' => {
#         'enabled' => true,
#         'label' => 'お切符',
#         'menu_label' => 'お切符',
#         'categories' => [
#           { 'key' => 'performance', 'label' => '公演' },
#           { 'key' => 'tea_party', 'label' => 'お茶会' },
#           { 'key' => 'other', 'label' => 'その他' },
#         ],
#       },
#       'blog' => {
#         'enabled' => true,
#         'label' => 'メッセージ',
#         'menu_label' => 'メッセージ',
#         'categories' => [
#           { 'key' => 'main', 'label' => '本人ブログ' },
#           { 'key' => 'movie', 'label' => 'ムービー' },
#           { 'key' => 'staff', 'label' => 'スタッフ' },
#         ],
#       },
#       'schedule' => { 'enabled' => false },
#       'profile' => { 'enabled' => true, 'label' => 'プロフィール', 'menu_label' => 'プロフィール', 'show_in_landing' => true },
#     },
#     landing: {
#       'sections_order' => %w[auth news blog profile],
#     },
#     login_label: 'ログイン',
#     signup_label: '新規会員登録',
#   )
#   site_settings.save!
# end
