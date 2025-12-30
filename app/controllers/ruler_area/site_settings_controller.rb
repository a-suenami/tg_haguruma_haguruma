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
      params.require(:site_setting).permit(
        :login_label,
        :signup_label,
        features: {},
      )
    end
  end
end
