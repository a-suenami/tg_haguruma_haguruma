# typed: true
# frozen_string_literal: true

module RulerArea
  class TagSettingsController < ApplicationController
    include RulerArea::TenantSettable

    before_action :set_tenant
    before_action :set_tag_setting

    def show; end

    def edit; end

    def update
      if @tag_setting.update(tag_setting_params)
        redirect_to ruler_area_tenant_tag_setting_path(@tenant), notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_tag_setting
      @tag_setting = @tenant.tag_settings || @tenant.build_tag_settings
    end

    def tag_setting_params
      params.require(:tag_setting).permit(:head_code, :body_code)
    end
  end
end
