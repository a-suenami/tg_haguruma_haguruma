# typed: false

# == Schema Information
#
# Table name: content_authorization_tags
#
#  id                                                             :uuid             not null, primary key
#  name                                                           :string           not null
#  provider(Tag provider: system, idp, ruler, or NULL for custom) :string
#  created_at                                                     :datetime         not null
#  updated_at                                                     :datetime         not null
#  remote_id(DEPRECATED: External system ID for synchronization)  :uuid
#  tenant_id                                                      :citext           not null
#  unique_id(Unique identifier within provider scope)             :string
#
# Indexes
#
#  index_content_authorization_tags_on_provider_unique_id       (tenant_id,provider,unique_id) UNIQUE WHERE (provider IS NOT NULL)
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

  PROVIDERS = {
    system: 'system',
    idp: 'idp',
    ruler: 'ruler',
  }.freeze

  SYSTEM_TAGS = {
    public: 'public',
    member: 'member',
  }.freeze

  has_many :user_tags, dependent: :destroy
  has_many :users, through: :user_tags
  has_many :content_entry_authorizations, dependent: :destroy

  enum :provider, PROVIDERS

  validates :name, presence: true, uniqueness: { scope: :tenant_id }
  validates :remote_id, uniqueness: { scope: :tenant_id }, allow_nil: true
  validates :unique_id, uniqueness: { scope: [:tenant_id, :provider] }, allow_nil: true

  scope :searchable, -> { where.not(provider: 'system') }

  class << self
    def find_or_create_system_tag!(unique_id:, name:)
      find_or_create_by!(provider: 'system', unique_id:) do |tag|
        tag.name = name
      end
    end

    def public_tag
      find_or_create_system_tag!(unique_id: SYSTEM_TAGS[:public], name: '公開')
    end

    def member_tag
      find_or_create_system_tag!(unique_id: SYSTEM_TAGS[:member], name: '会員限定')
    end
  end
end
