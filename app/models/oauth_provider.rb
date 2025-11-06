# typed: false
# frozen_string_literal: true

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
