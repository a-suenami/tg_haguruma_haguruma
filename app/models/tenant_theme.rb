# typed: strict
# frozen_string_literal: true

# == Schema Information
#
# Table name: tenant_themes
#
#  id                                :uuid             not null, primary key
#  border_color                      :string           default("#E5E5E5"), not null
#  button_font_family                :string           default("\"Noto Sans JP\", sans-serif"), not null
#  button_primary_background_color   :string           default("#0000FF"), not null
#  button_primary_text_color         :string           default("#FFFFFF"), not null
#  button_secondary_background_color :string           default("#FFFFFF"), not null
#  button_secondary_border_color     :string           default("#0000FF"), not null
#  button_secondary_text_color       :string           default("#0000FF"), not null
#  caption_font_family               :string           default("\"Noto Sans JP\", sans-serif"), not null
#  caption_text_color                :string           default("#666666"), not null
#  general_font_family               :string           default("\"Noto Sans JP\", sans-serif"), not null
#  general_text_color                :string           default("#000000"), not null
#  label_background_color            :string           default("#0000FF"), not null
#  label_font_family                 :string           default("\"Noto Sans JP\", sans-serif"), not null
#  label_text_color                  :string           default("#FFFFFF"), not null
#  link_text_color                   :string           default("#0000FF"), not null
#  link_underline                    :boolean          default(TRUE), not null
#  navigation_font_family            :string           default("\"Noto Serif JP\", serif"), not null
#  navigation_text_color             :string           default("#000000"), not null
#  page_background_color             :string           default("#FFFFFF"), not null
#  tab_active_text_color             :string           default("#0000FF"), not null
#  tab_active_underline_color        :string           default("#0000FF"), not null
#  tab_font_family                   :string           default("\"Noto Sans JP\", sans-serif"), not null
#  tab_inactive_text_color           :string           default("#666666"), not null
#  tab_inactive_underline_color      :string           default("#FFFFFF"), not null
#  title_font_family                 :string           default("\"Noto Serif JP\", serif"), not null
#  title_text_color                  :string           default("#000000"), not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  logo_media_asset_id               :uuid             not null
#  tenant_id                         :string           not null
#
# Indexes
#
#  index_tenant_themes_on_tenant_id  (tenant_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (logo_media_asset_id => media_assets.id)
#  fk_rails_...  (tenant_id => tenants.id)
#
class TenantTheme < ApplicationRecord
  extend T::Sig

  belongs_to :tenant, primary_key: :id
  belongs_to :logo_media_asset, class_name: 'MediaAsset'

  sig { returns(String) }
  def logo_url
    T.must(logo_media_asset).url.to_s
  end

  # Returns all CSS custom properties as a hash
  sig { returns(T::Hash[String, String]) }
  def css_custom_properties
    {
      # 全体背景
      '--theme-page-background-color' => page_background_color,

      # 一般（本文）テキスト
      '--theme-general-text-color' => general_text_color,
      '--theme-general-font-family' => general_font_family,

      # ボーダー
      '--theme-border-color' => border_color,

      # タイトル
      '--theme-title-text-color' => title_text_color,
      '--theme-title-font-family' => title_font_family,

      # ナビゲーション
      '--theme-navigation-text-color' => navigation_text_color,
      '--theme-navigation-font-family' => navigation_font_family,

      # リンク
      '--theme-link-text-color' => link_text_color,
      '--theme-link-underline' => link_underline ? 'underline' : 'none',

      # タブ
      '--theme-tab-font-family' => tab_font_family,
      '--theme-tab-active-text-color' => tab_active_text_color,
      '--theme-tab-active-underline-color' => tab_active_underline_color,
      '--theme-tab-inactive-text-color' => tab_inactive_text_color,
      '--theme-tab-inactive-underline-color' => tab_inactive_underline_color,

      # 補助テキスト
      '--theme-caption-text-color' => caption_text_color,
      '--theme-caption-font-family' => caption_font_family,

      # ラベル
      '--theme-label-background-color' => label_background_color,
      '--theme-label-text-color' => label_text_color,
      '--theme-label-font-family' => label_font_family,

      # ボタン（共通）
      '--theme-button-font-family' => button_font_family,

      # ボタン（Primary）
      '--theme-button-primary-background-color' => button_primary_background_color,
      '--theme-button-primary-text-color' => button_primary_text_color,

      # ボタン（Secondary）
      '--theme-button-secondary-border-color' => button_secondary_border_color,
      '--theme-button-secondary-background-color' => button_secondary_background_color,
      '--theme-button-secondary-text-color' => button_secondary_text_color,

      # 後方互換性のため旧変数も出力（段階的に移行）
      '--gearbox-primary' => label_background_color,
      '--gearbox-on-primary' => label_text_color,
      '--gearbox-secondary' => title_text_color,
      '--gearbox-on-secondary' => button_primary_text_color,
      '--gearbox-background' => page_background_color,
      '--gearbox-surface' => page_background_color,
      '--gearbox-on-surface' => general_text_color,
      '--gearbox-outline' => border_color,
      '--gearbox-font-family-heading' => title_font_family,
      '--gearbox-font-family-primary' => general_font_family,
    }
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
