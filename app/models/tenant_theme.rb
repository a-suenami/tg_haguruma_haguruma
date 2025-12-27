# typed: strict
# frozen_string_literal: true

# == Schema Information
#
# Table name: tenant_themes
#
#  id                   :uuid             not null, primary key
#  color_background     :string
#  color_on_primary     :string
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

  # Default values for CSS custom properties
  DEFAULT_COLORS = T.let({
    color_primary: '#F2719D',
    color_primary_dark: '#D4567D',
    color_secondary: '#FFD700',
    color_on_primary: '#FFFFFF',
    color_background: '#FFFFFF',
    color_surface: '#F5F5F5',
    color_text_primary: '#333333',
    color_text_secondary: '#666666',
    color_outline: '#E0E0E0',
  }.freeze, T::Hash[Symbol, String],)

  DEFAULT_FONTS = T.let({
    font_heading: 'Tsukimi Rounded',
    font_primary: 'Zen Maru Gothic',
  }.freeze, T::Hash[Symbol, String],)

  # Returns the color value or default
  sig { params(key: Symbol).returns(String) }
  def color(key)
    value = send(key)
    return value if value.present?

    DEFAULT_COLORS.fetch(key, '#000000')
  end

  # Returns the font value or default
  sig { params(key: Symbol).returns(String) }
  def font(key)
    value = send(key)
    return value if value.present?

    DEFAULT_FONTS.fetch(key, 'sans-serif')
  end

  # Returns all CSS custom properties as a hash
  sig { returns(T::Hash[String, String]) }
  def css_custom_properties
    {
      '--gearbox-primary' => color(:color_primary),
      '--gearbox-primary-dark' => color(:color_primary_dark),
      '--gearbox-secondary' => color(:color_secondary),
      '--gearbox-on-primary' => color(:color_on_primary),
      '--gearbox-background' => color(:color_background),
      '--gearbox-surface' => color(:color_surface),
      '--gearbox-text-primary' => color(:color_text_primary),
      '--gearbox-text-secondary' => color(:color_text_secondary),
      '--gearbox-outline-primary' => color(:color_outline),
      '--gearbox-font-family-heading' => font(:font_heading),
      '--gearbox-font-family-primary' => font(:font_primary),
    }
  end

  # Returns CSS style string for inline styles
  sig { returns(String) }
  def to_css_style
    css_custom_properties.map { |k, v| "#{k}: #{v}" }.join('; ')
  end
end
