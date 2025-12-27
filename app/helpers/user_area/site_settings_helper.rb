# frozen_string_literal: true

module UserArea
  module SiteSettingsHelper
    # Returns the current tenant's site settings
    def current_site_settings
      @current_site_settings ||= current_tenant&.site_settings_or_default || TenantSiteSettings.new
    end

    # Returns the current tenant's theme
    def current_theme
      @current_theme ||= current_tenant&.theme_or_default || TenantTheme.new
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
