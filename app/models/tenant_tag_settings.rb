# typed: strict
# frozen_string_literal: true

# == Schema Information
#
# Table name: tenant_tag_settings
#
#  id         :uuid             not null, primary key
#  head_code  :text
#  body_code  :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :string           not null
#
# Indexes
#
#  index_tenant_tag_settings_on_tenant_id  (tenant_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (tenant_id => tenants.id)
#
class TenantTagSettings < ApplicationRecord
  extend T::Sig

  belongs_to :tenant, primary_key: :id

  # Check if head code is configured
  sig { returns(T::Boolean) }
  def head_code?
    head_code.present?
  end

  # Check if body code is configured
  sig { returns(T::Boolean) }
  def body_code?
    body_code.present?
  end

  # Return head code as html_safe for rendering
  sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
  def head_code_html
    return nil unless head_code?

    head_code&.html_safe
  end

  # Return body code as html_safe for rendering
  sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
  def body_code_html
    return nil unless body_code?

    body_code&.html_safe
  end
end
