# typed: true
# frozen_string_literal: true

module RulerArea
  class SiteSettingsController < ApplicationController
    include RulerArea::TenantSettable

    before_action :set_tenant
    before_action :set_site_setting

    def show; end

    def edit; end

    def update
      if @site_setting.update(site_setting_params)
        redirect_to ruler_area_tenant_site_setting_path(@tenant), notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_site_setting
      @site_setting = @tenant.site_settings || @tenant.build_site_settings
    end

    def site_setting_params
      permitted = params.require(:site_setting).permit(
        :login_label,
        :signup_label,
        menu_items: %i[type key enabled label menu_label url position],
      )

      # Filter out empty menu_items (custom links with no key)
      if permitted[:menu_items].present?
        permitted[:menu_items] = permitted[:menu_items].reject do |item|
          item[:key].blank?
        end
      end

      # Handle features (nested hash with dynamic keys for each feature)
      permitted[:features] = process_features(params[:site_setting][:features])

      # Handle footer links (array of hashes with dynamic keys)
      permitted[:footer_main_links] = process_footer_links(params[:site_setting][:footer_main_links])
      permitted[:footer_sub_links] = process_footer_links(params[:site_setting][:footer_sub_links])

      permitted
    end

    def process_features(features_params)
      return {} if features_params.blank?

      features_params.to_unsafe_h.transform_values do |config|
        {
          'enabled' => config[:enabled] == 'true',
          'label' => config[:label],
          'menu_label' => config[:menu_label],
        }.compact
      end
    end

    def process_footer_links(links_params)
      return [] if links_params.blank?

      links_params.values.map do |link|
        {
          'key' => link[:key],
          'label' => link[:label],
          'url' => link[:url],
          'show_pc' => link[:show_pc] == 'true',
          'show_sp' => link[:show_sp] == 'true',
          'position' => link[:position].to_i,
          'is_logout' => link[:is_logout] == 'true',
        }.compact
      end.sort_by { |link| link['position'] }
    end
  end
end
