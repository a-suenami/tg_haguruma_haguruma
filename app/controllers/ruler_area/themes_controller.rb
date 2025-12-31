# typed: true
# frozen_string_literal: true

module RulerArea
  class ThemesController < ApplicationController
    include RulerArea::TenantSettable

    before_action :set_tenant
    before_action :set_theme

    def show; end

    def edit; end

    def update
      handle_logo_upload

      if @theme.update(theme_params)
        redirect_to ruler_area_tenant_theme_path(@tenant), notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_theme
      @theme = @tenant.theme || @tenant.build_theme
    end

    def handle_logo_upload
      logo_file = params.dig(:theme, :logo_file)
      return if logo_file.blank?

      uploader = MediaAsset::Uploader.new
      result = uploader.upload(
        file: logo_file,
        tenant_id: @tenant.id,
      )
      @theme.logo_media_asset = result[:media_asset]
    end

    def theme_params
      params.require(:theme).permit(
        :page_background_color,
        :general_text_color,
        :general_font_family,
        :border_color,
        :title_text_color,
        :title_font_family,
        :navigation_text_color,
        :navigation_font_family,
        :link_text_color,
        :link_underline,
        :tab_font_family,
        :tab_active_text_color,
        :tab_active_underline_color,
        :tab_inactive_text_color,
        :tab_inactive_underline_color,
        :caption_text_color,
        :caption_font_family,
        :label_background_color,
        :label_text_color,
        :label_font_family,
        :button_font_family,
        :button_primary_background_color,
        :button_primary_text_color,
        :button_secondary_border_color,
        :button_secondary_background_color,
        :button_secondary_text_color,
      )
    end
  end
end
