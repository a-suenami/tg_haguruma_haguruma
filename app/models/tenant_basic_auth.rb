# typed: strict
# frozen_string_literal: true

# == Schema Information
#
# Table name: tenant_basic_auths
#
#  id         :uuid             not null, primary key
#  enabled    :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :string           not null
#
# Indexes
#
#  index_tenant_basic_auths_on_tenant_id  (tenant_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (tenant_id => tenants.id)
#
class TenantBasicAuth < ApplicationRecord
  extend T::Sig

  belongs_to :tenant, primary_key: :id
  has_many :credentials, class_name: 'TenantBasicAuthCredential', dependent: :destroy

  sig { params(input_username: String, input_password: String).returns(T::Boolean) }
  def authenticate_credentials(input_username, input_password)
    return false unless enabled?

    credential = credentials.find_by(username: input_username)
    return false unless credential

    credential.valid_password?(input_password)
  end
end
