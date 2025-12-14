# typed: false

# == Schema Information
#
# Table name: content_authorization_tags
#
#  id                                                :uuid             not null, primary key
#  name                                              :string           not null
#  created_at                                        :datetime         not null
#  updated_at                                        :datetime         not null
#  remote_id(External system ID for synchronization) :uuid
#  tenant_id                                         :citext           not null
#
# Indexes
#
#  index_content_authorization_tags_on_tenant_id_and_id         (tenant_id,id) UNIQUE
#  index_content_authorization_tags_on_tenant_id_and_name       (tenant_id,name) UNIQUE
#  index_content_authorization_tags_on_tenant_id_and_remote_id  (tenant_id,remote_id) UNIQUE WHERE (remote_id IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (tenant_id => tenants.id)
#
class ContentAuthorizationTag < ApplicationRecord
  include Multitenancy

  has_many :user_tags, dependent: :destroy
  has_many :users, through: :user_tags
  has_many :content_entry_authorizations, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :tenant_id }
  validates :remote_id, uniqueness: { scope: :tenant_id }, allow_nil: true
end
