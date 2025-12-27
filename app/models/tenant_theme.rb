# typed: strict
# frozen_string_literal: true

# == Schema Information
#
# Table name: tenant_themes
#
#  id                                :uuid             not null, primary key
#  border_color                      :string
#  button_font_family                :string
#  button_primary_background_color   :string
#  button_primary_text_color         :string
#  button_secondary_background_color :string
#  button_secondary_border_color     :string
#  button_secondary_text_color       :string
#  caption_font_family               :string
#  caption_text_color                :string
#  general_font_family               :string
#  general_text_color                :string
#  label_background_color            :string
#  label_font_family                 :string
#  label_text_color                  :string
#  link_text_color                   :string
#  link_underline                    :boolean          default(TRUE)
#  navigation_font_family            :string
#  navigation_text_color             :string
#  page_background_color             :string
#  tab_active_text_color             :string
#  tab_active_underline_color        :string
#  tab_font_family                   :string
#  tab_inactive_text_color           :string
#  tab_inactive_underline_color      :string
#  title_font_family                 :string
#  title_text_color                  :string
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  tenant_id                         :string           not null
#
# Indexes
#
#  index_tenant_themes_on_tenant_id  (tenant_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (tenant_id => tenants.id)
#
class TenantTheme < ApplicationRecord
  extend T::Sig

  belongs_to :tenant, primary_key: :id

  # 静的なテーマ設定（検証用）
  # TODO: DB スキーマ確定後に削除
  STATIC_THEME_CONFIG = T.let({
    # 全体背景
    page_background_color: '#F8F8F8',

    # 一般（本文）テキスト
    general_text_color: '#333333',
    general_font_family: '"Noto Sans JP", sans-serif',

    # ボーダー
    border_color: '#E5E5E5',

    # タイトル
    title_text_color: '#1E3A5F',
    title_font_family: '"Noto Serif JP", serif',

    # ナビゲーション
    navigation_text_color: '#333333',
    navigation_font_family: '"Noto Serif JP", serif',

    # リンク
    link_text_color: '#1E3A5F',
    link_underline: true,

    # タブ
    tab_font_family: '"Noto Sans JP", sans-serif',
    tab_active_text_color: '#1E3A5F',
    tab_active_underline_color: '#1E3A5F',
    tab_inactive_text_color: '#666666',
    tab_inactive_underline_color: '#FFFFFF',

    # 補助テキスト
    caption_text_color: '#666666',
    caption_font_family: '"Noto Sans JP", sans-serif',

    # ラベル
    label_background_color: '#C9A227',
    label_text_color: '#FFFFFF',
    label_font_family: '"Noto Sans JP", sans-serif',

    # ボタン（共通）
    button_font_family: '"Noto Sans JP", sans-serif',

    # ボタン（Primary）
    button_primary_background_color: '#1E3A5F',
    button_primary_text_color: '#FFFFFF',

    # ボタン（Secondary）
    button_secondary_border_color: '#1E3A5F',
    button_secondary_background_color: '#FFFFFF',
    button_secondary_text_color: '#1E3A5F',
  }.freeze, T::Hash[Symbol, T.any(String, T::Boolean)])

  # Returns all CSS custom properties as a hash
  # DB カラムの値を優先し、nil の場合は STATIC_THEME_CONFIG のデフォルト値を使用
  sig { returns(T::Hash[String, T.nilable(String)]) }
  def css_custom_properties
    defaults = STATIC_THEME_CONFIG

    # DB カラムから値を取得（nil の場合はデフォルト値を使用）
    page_bg = page_background_color || defaults[:page_background_color]
    general_text = general_text_color || defaults[:general_text_color]
    general_font = general_font_family || defaults[:general_font_family]
    border = border_color || defaults[:border_color]
    title_text = title_text_color || defaults[:title_text_color]
    title_font = title_font_family || defaults[:title_font_family]
    nav_text = navigation_text_color || defaults[:navigation_text_color]
    nav_font = navigation_font_family || defaults[:navigation_font_family]
    link_text = link_text_color || defaults[:link_text_color]
    link_ul = link_underline.nil? ? defaults[:link_underline] : link_underline
    tab_font = tab_font_family || defaults[:tab_font_family]
    tab_active_text = tab_active_text_color || defaults[:tab_active_text_color]
    tab_active_ul = tab_active_underline_color || defaults[:tab_active_underline_color]
    tab_inactive_text = tab_inactive_text_color || defaults[:tab_inactive_text_color]
    tab_inactive_ul = tab_inactive_underline_color || defaults[:tab_inactive_underline_color]
    caption_text = caption_text_color || defaults[:caption_text_color]
    caption_font = caption_font_family || defaults[:caption_font_family]
    label_bg = label_background_color || defaults[:label_background_color]
    label_text = label_text_color || defaults[:label_text_color]
    label_font = label_font_family || defaults[:label_font_family]
    btn_font = button_font_family || defaults[:button_font_family]
    btn_primary_bg = button_primary_background_color || defaults[:button_primary_background_color]
    btn_primary_text = button_primary_text_color || defaults[:button_primary_text_color]
    btn_secondary_border = button_secondary_border_color || defaults[:button_secondary_border_color]
    btn_secondary_bg = button_secondary_background_color || defaults[:button_secondary_background_color]
    btn_secondary_text = button_secondary_text_color || defaults[:button_secondary_text_color]

    props = {
      # 全体背景
      '--theme-page-background-color' => page_bg,

      # 一般（本文）テキスト
      '--theme-general-text-color' => general_text,
      '--theme-general-font-family' => general_font,

      # ボーダー
      '--theme-border-color' => border,

      # タイトル
      '--theme-title-text-color' => title_text,
      '--theme-title-font-family' => title_font,

      # ナビゲーション
      '--theme-navigation-text-color' => nav_text,
      '--theme-navigation-font-family' => nav_font,

      # リンク
      '--theme-link-text-color' => link_text,
      '--theme-link-underline' => link_ul ? 'underline' : 'none',

      # タブ
      '--theme-tab-font-family' => tab_font,
      '--theme-tab-active-text-color' => tab_active_text,
      '--theme-tab-active-underline-color' => tab_active_ul,
      '--theme-tab-inactive-text-color' => tab_inactive_text,
      '--theme-tab-inactive-underline-color' => tab_inactive_ul,

      # 補助テキスト
      '--theme-caption-text-color' => caption_text,
      '--theme-caption-font-family' => caption_font,

      # ラベル
      '--theme-label-background-color' => label_bg,
      '--theme-label-text-color' => label_text,
      '--theme-label-font-family' => label_font,

      # ボタン（共通）
      '--theme-button-font-family' => btn_font,

      # ボタン（Primary）
      '--theme-button-primary-background-color' => btn_primary_bg,
      '--theme-button-primary-text-color' => btn_primary_text,

      # ボタン（Secondary）
      '--theme-button-secondary-border-color' => btn_secondary_border,
      '--theme-button-secondary-background-color' => btn_secondary_bg,
      '--theme-button-secondary-text-color' => btn_secondary_text,

      # 後方互換性のため旧変数も出力（段階的に移行）
      '--gearbox-primary' => label_bg,
      '--gearbox-on-primary' => label_text,
      '--gearbox-secondary' => title_text,
      '--gearbox-on-secondary' => btn_primary_text,
      '--gearbox-background' => page_bg,
      '--gearbox-surface' => page_bg,
      '--gearbox-on-surface' => general_text,
      '--gearbox-outline' => border,
      '--gearbox-font-family-heading' => title_font,
      '--gearbox-font-family-primary' => general_font,
    }

    props.transform_values(&:to_s).compact
  end

  private

  # Convert hex color to RGB string for CSS rgba() usage
  sig { params(hex: T.nilable(String)).returns(T.nilable(String)) }
  def hex_to_rgb(hex)
    return nil unless hex&.match?(/\A#[0-9A-Fa-f]{6}\z/)

    r = T.must(hex[1..2]).to_i(16)
    g = T.must(hex[3..4]).to_i(16)
    b = T.must(hex[5..6]).to_i(16)
    "#{r}, #{g}, #{b}"
  end

  # Returns CSS style string for inline styles
  sig { returns(String) }
  def to_css_style
    css_custom_properties.map { |k, v| "#{k}: #{v}" }.join('; ')
  end
end
