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

  # Returns all CSS custom properties as a hash
  sig { returns(T::Hash[String, T.nilable(String)]) }
  def css_custom_properties
    {
      '--gearbox-primary' => color_primary,
      '--gearbox-primary-dark' => color_primary_dark,
      '--gearbox-secondary' => color_secondary,
      '--gearbox-on-primary' => color_on_primary,
      '--gearbox-background' => color_background,
      '--gearbox-surface' => color_surface,
      '--gearbox-text-primary' => color_text_primary,
      '--gearbox-text-secondary' => color_text_secondary,
      '--gearbox-outline-primary' => color_outline,
      '--gearbox-font-family-heading' => font_heading,
      '--gearbox-font-family-primary' => font_primary,
    }.compact
  end

  # Returns CSS style string for inline styles
  sig { returns(String) }
  def to_css_style
    css_custom_properties.map { |k, v| "#{k}: #{v}" }.join('; ')
  end
end
