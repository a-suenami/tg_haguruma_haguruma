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
    # 全体背景
    page_background_color: '#FFFFFF',

    # 一般（本文）テキスト
    general_text_color: '#333333',
    general_font_family: '"Zen Maru Gothic", sans-serif',

    # ボーダー
    border_color: '#E0E0E0',

    # タイトル
    title_text_color: '#F2719D',
    title_font_family: '"Tsukimi Rounded", sans-serif',

    # ナビゲーション
    navigation_text_color: '#333333',
    navigation_font_family: '"Tsukimi Rounded", sans-serif',

    # リンク
    link_text_color: '#F2719D',
    link_underline: true,

    # タブ
    tab_font_family: '"Zen Maru Gothic", sans-serif',
    tab_active_text_color: '#F2719D',
    tab_active_underline_color: '#F2719D',
    tab_inactive_text_color: '#666666',
    tab_inactive_underline_color: '#FFFFFF',

    # 補助テキスト
    caption_text_color: '#666666',
    caption_font_family: '"Zen Maru Gothic", sans-serif',

    # ラベル
    label_background_color: '#F2719D',
    label_text_color: '#FFFFFF',
    label_font_family: '"Zen Maru Gothic", sans-serif',

    # ボタン（共通）
    button_font_family: '"Zen Maru Gothic", sans-serif',

    # ボタン（Primary）
    button_primary_background_color: '#F2719D',
    button_primary_text_color: '#FFFFFF',

    # ボタン（Secondary）
    button_secondary_border_color: '#F2719D',
    button_secondary_background_color: '#FFFFFF',
    button_secondary_text_color: '#F2719D',
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
# Dev Tenant (modern dark theme for local development)
# -----------------------------------------------------------------------------
dev_tenant = Tenant.find_by(id: 'dev-tenant')

if dev_tenant
  # Create dummy logo MediaAsset (required for theme)
  logo = MediaAsset.find_or_initialize_by(tenant_id: dev_tenant.id, s3_object_path: 'seed/dev-tenant-logo.png')
  logo.assign_attributes(
    media_type: 'image',
    mime_type: 'image/png',
    file_size_bytes: 1024,
    metadata: { width: 200, height: 60, placeholder: true },
  )
  logo.save!

  # Theme (modern dark blue/cyan theme)
  theme = TenantTheme.find_or_initialize_by(tenant_id: dev_tenant.id)
  theme.assign_attributes(
    logo_media_asset: logo,

    # 全体背景
    page_background_color: '#0F172A',

    # 一般（本文）テキスト
    general_text_color: '#E2E8F0',
    general_font_family: '"Inter", "Noto Sans JP", sans-serif',

    # ボーダー
    border_color: '#334155',

    # タイトル
    title_text_color: '#22D3EE',
    title_font_family: '"Inter", "Noto Sans JP", sans-serif',

    # ナビゲーション
    navigation_text_color: '#E2E8F0',
    navigation_font_family: '"Inter", "Noto Sans JP", sans-serif',

    # リンク
    link_text_color: '#38BDF8',
    link_underline: false,

    # タブ
    tab_font_family: '"Inter", "Noto Sans JP", sans-serif',
    tab_active_text_color: '#22D3EE',
    tab_active_underline_color: '#22D3EE',
    tab_inactive_text_color: '#94A3B8',
    tab_inactive_underline_color: '#1E293B',

    # 補助テキスト
    caption_text_color: '#94A3B8',
    caption_font_family: '"Inter", "Noto Sans JP", sans-serif',

    # ラベル
    label_background_color: '#0891B2',
    label_text_color: '#FFFFFF',
    label_font_family: '"Inter", "Noto Sans JP", sans-serif',

    # ボタン（共通）
    button_font_family: '"Inter", "Noto Sans JP", sans-serif',

    # ボタン（Primary）
    button_primary_background_color: '#0891B2',
    button_primary_text_color: '#FFFFFF',

    # ボタン（Secondary）
    button_secondary_border_color: '#22D3EE',
    button_secondary_background_color: '#1E293B',
    button_secondary_text_color: '#22D3EE',
  )

  if theme.save
    Rails.logger.debug { "  ✅ TenantTheme: #{dev_tenant.name}" }
  else
    Rails.logger.debug { "  ❌ Failed: #{theme.errors.full_messages.join(', ')}" }
  end

  # Site Settings (all features enabled for testing)
  site_settings = TenantSiteSettings.find_or_initialize_by(tenant_id: dev_tenant.id)
  site_settings.assign_attributes(
    features: {
      'news' => { 'enabled' => true, 'label' => 'NEWS', 'menu_label' => 'NEWS' },
      'ticket' => { 'enabled' => true, 'label' => 'TICKET', 'menu_label' => 'TICKET' },
      'blog' => { 'enabled' => true, 'label' => 'BLOG', 'menu_label' => 'BLOG' },
      'schedule' => { 'enabled' => true, 'label' => 'SCHEDULE', 'menu_label' => 'SCHEDULE' },
      'biography' => { 'enabled' => true, 'label' => 'BIOGRAPHY', 'menu_label' => 'PROFILE' },
    },
    menu_items: [
      { 'type' => 'feature', 'key' => 'news', 'enabled' => true, 'label' => 'NEWS', 'menu_label' => 'NEWS', 'position' => 1 },
      { 'type' => 'feature', 'key' => 'blog', 'enabled' => true, 'label' => 'BLOG', 'menu_label' => 'BLOG', 'position' => 2 },
      { 'type' => 'feature', 'key' => 'ticket', 'enabled' => true, 'label' => 'TICKET', 'menu_label' => 'TICKET', 'position' => 3 },
      { 'type' => 'feature', 'key' => 'schedule', 'enabled' => true, 'label' => 'SCHEDULE', 'menu_label' => 'SCHEDULE', 'position' => 4 },
      { 'type' => 'custom', 'key' => 'twogate', 'enabled' => true, 'label' => 'TwoGate', 'url' => 'https://twogate.com', 'position' => 5 },
      { 'type' => 'feature', 'key' => 'biography', 'enabled' => false, 'label' => 'BIOGRAPHY', 'menu_label' => 'PROFILE', 'position' => 6 },
    ],
    landing: {
      'sections_order' => %w[auth news blog],
    },
    login_label: 'ログイン',
    signup_label: '新規登録',
  )

  if site_settings.save
    Rails.logger.debug { "  ✅ TenantSiteSettings: #{dev_tenant.name}" }
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
#   # Theme (紺色/金色 design - 斧琴菊スタイル)
#   theme = TenantTheme.find_or_initialize_by(tenant_id: yokotogiku_tenant.id)
#   theme.assign_attributes(
#     # 全体背景
#     page_background_color: '#F8F8F8',
#
#     # 一般（本文）テキスト
#     general_text_color: '#333333',
#     general_font_family: '"Noto Sans JP", sans-serif',
#
#     # ボーダー
#     border_color: '#E5E5E5',
#
#     # タイトル
#     title_text_color: '#1E3A5F',
#     title_font_family: '"Noto Serif JP", serif',
#
#     # ナビゲーション
#     navigation_text_color: '#333333',
#     navigation_font_family: '"Noto Serif JP", serif',
#
#     # リンク
#     link_text_color: '#1E3A5F',
#     link_underline: true,
#
#     # タブ
#     tab_font_family: '"Noto Sans JP", sans-serif',
#     tab_active_text_color: '#1E3A5F',
#     tab_active_underline_color: '#1E3A5F',
#     tab_inactive_text_color: '#666666',
#     tab_inactive_underline_color: '#FFFFFF',
#
#     # 補助テキスト
#     caption_text_color: '#666666',
#     caption_font_family: '"Noto Sans JP", sans-serif',
#
#     # ラベル
#     label_background_color: '#C9A227',
#     label_text_color: '#FFFFFF',
#     label_font_family: '"Noto Sans JP", sans-serif',
#
#     # ボタン（共通）
#     button_font_family: '"Noto Sans JP", sans-serif',
#
#     # ボタン（Primary）
#     button_primary_background_color: '#1E3A5F',
#     button_primary_text_color: '#FFFFFF',
#
#     # ボタン（Secondary）
#     button_secondary_border_color: '#1E3A5F',
#     button_secondary_background_color: '#FFFFFF',
#     button_secondary_text_color: '#1E3A5F',
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
#       'biography' => { 'enabled' => true, 'label' => 'プロフィール', 'menu_label' => 'プロフィール', 'show_in_landing' => true },
#     },
#     landing: {
#       'sections_order' => %w[auth news blog biography],
#     },
#     login_label: 'ログイン',
#     signup_label: '新規会員登録',
#   )
#   site_settings.save!
# end
