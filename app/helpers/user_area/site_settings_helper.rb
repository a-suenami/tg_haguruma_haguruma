# frozen_string_literal: true

module UserArea
  module SiteSettingsHelper
    # Returns the current tenant's site settings (with fallback to defaults if missing)
    def current_site_settings
      @current_site_settings ||= current_tenant&.site_settings_or_default
    end

    # Returns the current tenant's theme (with fallback to defaults if missing)
    def current_theme
      @current_theme ||= current_tenant&.theme_or_default
    end

    # Returns the current tenant's tag settings (with fallback to empty if missing)
    def current_tag_settings
      @current_tag_settings ||= current_tenant&.tag_settings_or_default
    end

    # Check if a feature is enabled
    delegate :feature_enabled?, to: :current_site_settings

    # Get feature label
    def feature_label(feature_key, label_type = :label)
      current_site_settings.feature_label(feature_key, label_type)
    end

    # Get feature categories
    delegate :feature_categories, to: :current_site_settings

    # Get login button label
    delegate :login_label, to: :current_site_settings

    # Get signup button label
    delegate :signup_label, to: :current_site_settings

    # Get landing sections in order
    delegate :landing_sections_order, to: :current_site_settings

    # Get enabled features for PC header
    delegate :enabled_features, to: :current_site_settings

    # Get ordered menu items for SP/mobile menu (features + custom links combined)
    delegate :ordered_menu_items, to: :current_site_settings

    # Get URL for menu item
    def menu_item_url(item)
      case item['type']
      when 'feature'
        feature_path(item['key'])
      when 'custom'
        item['url']
      end
    end

    # Get feature path by key
    def feature_path(key)
      case key
      when 'news' then user_area_news_index_path
      when 'ticket' then user_area_tickets_path
      when 'blog' then user_area_blog_index_path
      when 'schedule' then user_area_schedules_path
      when 'biography' then user_area_biography_path
      else '#'
      end
    end

    # Check if URL is external
    def external_url?(url)
      url.present? && (url.start_with?('http://') || url.start_with?('https://'))
    end

    # Output CSS custom properties as inline style
    def theme_css_variables
      current_theme.to_css_style
    end

    # Output CSS custom properties as style tag content
    def theme_css_style_tag
      props = current_theme.css_custom_properties
      css = props.map { |k, v| "  #{k}: #{v};" }.join("\n")
      ":root {\n#{css}\n}".html_safe
    end
  end
end
