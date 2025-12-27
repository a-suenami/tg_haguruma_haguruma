# typed: strict
# frozen_string_literal: true

# == Schema Information
#
# Table name: tenant_themes
#
#  id                   :uuid             not null, primary key
#  color_background     :string
#  color_on_primary     :string
#  color_on_secondary   :string
#  color_outline        :string
#  color_primary        :string
#  color_primary_dark   :string
#  color_secondary      :string
#  color_surface        :string
#  color_text_primary   :string
#  color_text_secondary :string
#  font_heading         :string
#  font_primary         :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  tenant_id            :string           not null
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
  sig { returns(T::Hash[String, T.nilable(String)]) }
  def css_custom_properties
    config = STATIC_THEME_CONFIG

    props = {
      # 全体背景
      '--theme-page-background-color' => config[:page_background_color],

      # 一般（本文）テキスト
      '--theme-general-text-color' => config[:general_text_color],
      '--theme-general-font-family' => config[:general_font_family],

      # ボーダー
      '--theme-border-color' => config[:border_color],

      # タイトル
      '--theme-title-text-color' => config[:title_text_color],
      '--theme-title-font-family' => config[:title_font_family],

      # ナビゲーション
      '--theme-navigation-text-color' => config[:navigation_text_color],
      '--theme-navigation-font-family' => config[:navigation_font_family],

      # リンク
      '--theme-link-text-color' => config[:link_text_color],
      '--theme-link-underline' => config[:link_underline] ? 'underline' : 'none',

      # タブ
      '--theme-tab-font-family' => config[:tab_font_family],
      '--theme-tab-active-text-color' => config[:tab_active_text_color],
      '--theme-tab-active-underline-color' => config[:tab_active_underline_color],
      '--theme-tab-inactive-text-color' => config[:tab_inactive_text_color],
      '--theme-tab-inactive-underline-color' => config[:tab_inactive_underline_color],

      # 補助テキスト
      '--theme-caption-text-color' => config[:caption_text_color],
      '--theme-caption-font-family' => config[:caption_font_family],

      # ラベル
      '--theme-label-background-color' => config[:label_background_color],
      '--theme-label-text-color' => config[:label_text_color],
      '--theme-label-font-family' => config[:label_font_family],

      # ボタン（共通）
      '--theme-button-font-family' => config[:button_font_family],

      # ボタン（Primary）
      '--theme-button-primary-background-color' => config[:button_primary_background_color],
      '--theme-button-primary-text-color' => config[:button_primary_text_color],

      # ボタン（Secondary）
      '--theme-button-secondary-border-color' => config[:button_secondary_border_color],
      '--theme-button-secondary-background-color' => config[:button_secondary_background_color],
      '--theme-button-secondary-text-color' => config[:button_secondary_text_color],

      # 後方互換性のため旧変数も出力（段階的に移行）
      '--gearbox-primary' => config[:label_background_color],
      '--gearbox-on-primary' => config[:label_text_color],
      '--gearbox-secondary' => config[:title_text_color],
      '--gearbox-on-secondary' => config[:button_primary_text_color],
      '--gearbox-background' => config[:page_background_color],
      '--gearbox-surface' => config[:page_background_color],
      '--gearbox-on-surface' => config[:general_text_color],
      '--gearbox-outline' => config[:border_color],
      '--gearbox-font-family-heading' => config[:title_font_family],
      '--gearbox-font-family-primary' => config[:general_font_family],
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
