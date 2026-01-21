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
  before_save :normalize_menu_items

  validate :unique_menu_item_keys

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

  # Get ordered menu items (features + custom links combined)
  # Returns array sorted by position for rendering in SP/mobile menu
  sig { returns(T::Array[T::Hash[String, T.untyped]]) }
  def ordered_menu_items
    all_menu_items_for_form
      .select { |item| item['enabled'] == true }
      .sort_by { |item| item['position'].to_i }
  end

  # Get all menu items for ruler form (includes disabled features and custom links)
  # Uses unified menu_items if present, otherwise builds from defaults
  sig { returns(T::Array[T::Hash[String, T.untyped]]) }
  def all_menu_items_for_form
    # If menu_items is empty, build default from DEFAULT_FEATURES
    if menu_items.blank?
      return build_default_menu_items
    end

    items = menu_items.dup

    # Ensure all default features exist in menu_items (in case new features added)
    existing_keys = items.select { |i| i['type'] == 'feature' }.pluck('key')
    missing_features = DEFAULT_FEATURES.keys - existing_keys

    missing_features.each_with_index do |key, idx|
      defaults = T.must(DEFAULT_FEATURES[key])
      items << {
        'type' => 'feature',
        'key' => key,
        'enabled' => false,
        'label' => defaults['label'],
        'menu_label' => defaults['menu_label'],
        'position' => 100 + idx, # Add at the end
      }
    end

    # Ensure logout link exists (added by default, cannot be deleted)
    logout_exists = items.any? { |i| i['key'] == 'logout' }
    unless logout_exists
      items << {
        'type' => 'custom',
        'key' => 'logout',
        'enabled' => true,
        'label' => 'ログアウト',
        'url' => '/logout',
        'position' => 999, # Add at the very end
      }
    end

    items.sort_by { |item| item['position'].to_i }
  end

  # Build default menu items from DEFAULT_FEATURES + logout link
  sig { returns(T::Array[T::Hash[String, T.untyped]]) }
  def build_default_menu_items
    items = DEFAULT_FEATURES.map.with_index do |(key, config), index|
      {
        'type' => 'feature',
        'key' => key,
        'enabled' => config['enabled'],
        'label' => config['label'],
        'menu_label' => config['menu_label'],
        'position' => index + 1,
      }
    end

    # Add default logout link at the end (like IDP)
    items << {
      'type' => 'custom',
      'key' => 'logout',
      'enabled' => true,
      'label' => 'ログアウト',
      'url' => '/logout',
      'position' => items.size + 1,
    }

    items
  end

  private

  sig { void }
  def normalize_features
    return if features.blank?

    T.must(features).each_value do |config|
      config['enabled'] = ActiveModel::Type::Boolean.new.cast(config['enabled'])
      config['menu_order'] = config['menu_order'].to_i if config['menu_order'].present?
    end
  end

  sig { void }
  def normalize_menu_items
    return if menu_items.blank?

    # Convert ActionController::Parameters to array of hashes and normalize values
    self.menu_items = menu_items.map do |item|
      item = item.to_h if item.respond_to?(:to_h)
      normalized = {
        'type' => item['type'] || item[:type],
        'key' => item['key'] || item[:key],
        'enabled' => ActiveModel::Type::Boolean.new.cast(item['enabled'] || item[:enabled]),
        'label' => item['label'] || item[:label],
        'menu_label' => item['menu_label'] || item[:menu_label],
        'position' => (item['position'] || item[:position]).to_i,
      }
      # Only include url for custom links
      if normalized['type'] == 'custom'
        normalized['url'] = item['url'] || item[:url]
      end
      normalized
    end.reject { |item| item['key'].blank? }
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

  sig { void }
  def unique_menu_item_keys
    return if menu_items.blank?

    keys = menu_items.map { |item| item['key'] || item[:key] }.compact
    duplicates = keys.group_by(&:itself).select { |_, v| v.size > 1 }.keys

    return if duplicates.empty?

    errors.add(:menu_items, "に重複するキーがあります: #{duplicates.join(', ')}")
  end
end
