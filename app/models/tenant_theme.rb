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

  # Returns all CSS custom properties as a hash
  sig { returns(T::Hash[String, T.nilable(String)]) }
  def css_custom_properties
    props = {
      # Primary colors (accent, category labels)
      '--gearbox-primary' => color_primary,
      '--gearbox-primary-dark' => color_primary_dark,
      '--gearbox-on-primary' => color_on_primary,

      # Secondary colors (titles, buttons, navigation)
      '--gearbox-secondary' => color_secondary,
      '--gearbox-on-secondary' => color_on_secondary,
      '--gearbox-secondary-container' => color_surface,
      '--gearbox-on-secondary-container' => color_secondary,

      # Surface colors
      '--gearbox-background' => color_background,
      '--gearbox-surface' => color_surface,
      '--gearbox-on-surface' => color_text_primary,

      # Outline
      '--gearbox-outline' => color_outline,
      '--gearbox-outline-primary' => color_primary,
      '--gearbox-outline-secondary' => color_secondary,
      '--gearbox-outline-variant' => color_outline,

      # Fonts
      '--gearbox-font-family-heading' => font_heading,
      '--gearbox-font-family-primary' => font_primary,
    }

    # Add RGB versions for rgba() usage
    props['--gearbox-on-surface-rgb'] = hex_to_rgb(color_text_primary) if color_text_primary

    props.compact
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
