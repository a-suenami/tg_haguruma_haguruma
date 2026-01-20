# typed: strict

# == Schema Information
#
# Table name: tenants
#
#  id               :string           not null, primary key
#  name             :string
#  user_page_domain :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Tenant < ApplicationRecord
  extend T::Sig

  has_many :admins, dependent: :destroy
  has_one :oauth_provider
  has_one :theme, class_name: 'TenantTheme', dependent: :destroy
  has_one :site_settings, class_name: 'TenantSiteSettings', dependent: :destroy

  validates :id, :name, presence: true
  validates :id, uniqueness: { case_sensitive: false }
  validates :id, format: { with: /\A[a-z0-9][a-z0-9-]+[a-z0-9]\z/ }, if: proc { Array(Settings.models.tenant.manually_allow_ids).exclude?(_1.id&.downcase) }
  validate :validate_id

  class << self
    extend T::Sig

    sig { returns(T.nilable(String)) }
    def current_id
      RequestStore.store[:current_tenant]&.to_s
    end

    sig { returns(T.nilable(Tenant)) }
    def current
      return if self.current_id.blank?

      # cache がない場合
      if RequestStore.store[:current_tenant_object].blank?
        RequestStore.store[:current_tenant_object] = self.find(T.must(self.current_id))
      end

      # cache と current_id が違う場合は取得し直す
      if RequestStore.store[:current_tenant_object].id != self.current_id
        RequestStore.store[:current_tenant_object] = self.find(T.must(self.current_id))
      end

      RequestStore.store[:current_tenant_object]
    end

    sig { returns(Tenant) }
    def current!
      T.must(self.current)
    end

    sig { params(id: T.any(String, Symbol, NilClass)).returns(String) }
    def current_id=(id)
      RequestStore.store[:current_tenant] = id.to_s
    end
  end

  sig { void }
  def validate_id
    if ReservedSubdomain.new(id.downcase).reserved? && Array(Settings.models.tenant.manually_allow_ids).exclude?(id.downcase)
      errors.add(:base, :reserved_id_error)
    end
  end

  # path: `/` から始まる必要あり（`/my-page` など）
  # params: `[[key, value], [key, value]]` の形式
  sig { params(path: String, params: T::Array[[String, String]]).returns(String) }
  def user_page_path(path = '/', params: [])
    uri = URI::HTTPS.build(
      host: T.must(self.user_page_domain),
      path:,
      query: params.to_h.to_query.presence,
    )

    uri.to_s
  end

  # Returns theme or a null object with defaults
  sig { returns(TenantTheme) }
  def theme_or_default
    theme || TenantTheme.new
  end

  # Returns site settings or a null object with defaults
  sig { returns(TenantSiteSettings) }
  def site_settings_or_default
    site_settings || TenantSiteSettings.new
  end

  # TODO: Add these methods when config model is ported
  # sig { returns(T::Boolean) }
  # def push_user_mail_event_enabled?
  #   !!self.config&.push_user_mail_event_enabled?
  # end

  # sig { returns(T::Boolean) }
  # def phone_number_verification_enabled?
  #   !!self.config&.phone_number_verification_enabled?
  # end

  # sig { returns(T::Boolean) }
  # def verified_phone_number_change_allowed?
  #   !!self.config&.verified_phone_number_change_allowed?
  # end
end
