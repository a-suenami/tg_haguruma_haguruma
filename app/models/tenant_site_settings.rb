# typed: strict
# frozen_string_literal: true

# == Schema Information
#
# Table name: tenant_site_settings
#
#  id           :uuid             not null, primary key
#  features     :jsonb            not null
#  landing      :jsonb            not null
#  login_label  :string           default("ログイン"), not null
#  signup_label :string           default("新規会員登録"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  tenant_id    :string           not null
#
# Indexes
#
#  index_tenant_site_settings_on_tenant_id  (tenant_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (tenant_id => tenants.id)
#
class TenantSiteSettings < ApplicationRecord
  extend T::Sig

  belongs_to :tenant, primary_key: :id

  before_save :normalize_features

  # Default feature configuration (all disabled by default - must be enabled per tenant)
  DEFAULT_FEATURES = T.let({
    'news' => {
      'enabled' => false,
      'label' => 'NEWS',
      'menu_label' => 'NEWS',
      'show_in_landing' => false,
      'landing_order' => 1,
    },
    'ticket' => {
      'enabled' => false,
      'label' => 'TICKET',
      'menu_label' => 'TICKET',
      'show_in_landing' => false,
      'landing_order' => 2,
    },
    'blog' => {
      'enabled' => false,
      'label' => 'BLOG',
      'menu_label' => 'BLOG',
      'show_in_landing' => false,
      'landing_order' => 3,
    },
    'schedule' => {
      'enabled' => false,
      'label' => 'SCHEDULE',
      'menu_label' => 'SCHEDULE',
      'show_in_landing' => false,
      'landing_order' => 4,
    },
    'biography' => {
      'enabled' => false,
      'label' => 'BIOGRAPHY',
      'menu_label' => 'BIOGRAPHY',
      'show_in_landing' => false,
      'landing_order' => 5,
    },
  }.freeze, T::Hash[String, T::Hash[String, T.untyped]],)

  DEFAULT_LANDING = T.let({
    'sections_order' => %w[auth news blog],
  }.freeze, T::Hash[String, T.untyped],)

  # Check if a feature is enabled
  sig { params(feature_key: T.any(String, Symbol)).returns(T::Boolean) }
  def feature_enabled?(feature_key)
    feature = feature_config(feature_key.to_s)
    feature['enabled'] == true
  end

  # Get feature label
  sig { params(feature_key: T.any(String, Symbol), label_type: Symbol).returns(String) }
  def feature_label(feature_key, label_type = :label)
    feature = feature_config(feature_key.to_s)
    feature[label_type.to_s] || feature['label'] || feature_key.to_s.upcase
  end

  # Get feature categories
  sig { params(feature_key: T.any(String, Symbol)).returns(T::Array[T::Hash[String, String]]) }
  def feature_categories(feature_key)
    feature = feature_config(feature_key.to_s)
    feature['categories'] || []
  end

  # Get all enabled features sorted by menu order
  sig { returns(T::Array[T::Hash[String, T.untyped]]) }
  def enabled_features
    merged_features
      .select { |_key, config| config['enabled'] == true }
      .sort_by { |_key, config| config['menu_order'] || config['landing_order'] || 999 }
      .map { |key, config| config.merge('key' => key) }
  end

  # Get landing page sections in order
  sig { returns(T::Array[String]) }
  def landing_sections_order
    landing_config['sections_order'] || DEFAULT_LANDING['sections_order']
  end

  private

  sig { void }
  def normalize_features
    return if features.blank?

    T.must(features).each_value do |config|
      config['enabled'] = ActiveModel::Type::Boolean.new.cast(config['enabled'])
    end
  end

  sig { params(feature_key: String).returns(T::Hash[String, T.untyped]) }
  def feature_config(feature_key)
    merged_features[feature_key] || {}
  end

  sig { returns(T::Hash[String, T::Hash[String, T.untyped]]) }
  def merged_features
    DEFAULT_FEATURES.merge(features || {}) do |_key, default, custom|
      default.merge(custom)
    end
  end

  sig { returns(T::Hash[String, T.untyped]) }
  def landing_config
    DEFAULT_LANDING.merge(landing || {})
  end
end
