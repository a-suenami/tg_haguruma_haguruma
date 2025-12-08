# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: oauth_providers
#
#  id                                                         :uuid             not null, primary key
#  client_secret                                              :string
#  endpoint_base                                              :string           not null
#  keypath_uid(UIDを取得するためのkeypath (デフォルト: sub))  :string
#  kind(user or admin)                                        :string           default("user"), not null
#  scopes                                                     :string           default(""), not null
#  session_expires_in(セッショントークンの有効期間 (90 days)) :integer          default(7776000), not null
#  created_at                                                 :datetime         not null
#  updated_at                                                 :datetime         not null
#  client_id                                                  :string           not null
#  tenant_id                                                  :string           not null
#
# Indexes
#
#  index_oauth_providers_on_tenant_id           (tenant_id)
#  index_oauth_providers_on_tenant_id_and_kind  (tenant_id,kind) UNIQUE WHERE ((kind)::text = 'user'::text)
#
# Foreign Keys
#
#  fk_rails_...  (tenant_id => tenants.id)
#
class OauthProvider < ApplicationRecord
  extend T::Sig

  belongs_to :tenant, primary_key: :id
  has_many :users

  validates :client_id, presence: true
  validates :endpoint_base, presence: true
  validates :kind, presence: true

  class KindEnum < T::Enum
    enums do
      User = new('user')
      Admin = new('admin')
    end
  end

  enumerize :kind, enum_class: KindEnum

  scope :user_app,  -> { where(kind: 'user') }
  scope :admin_app, -> { where(kind: 'admin') }
end
