# typed: true
# frozen_string_literal: true

module RulerArea
  class AuthorizationTagsController < ApplicationController
    include RulerArea::TenantSettable

    before_action :set_tenant
    before_action :set_authorization_tag, only: [:edit, :update, :destroy]

    def index
      @authorization_tags = ContentAuthorizationTag.order(:name)
    end

    def new
      @authorization_tag = ContentAuthorizationTag.new
    end

    def edit; end

    def create
      @authorization_tag = ContentAuthorizationTag.new(authorization_tag_params)
      @authorization_tag.tenant_id = @tenant.id
      @authorization_tag.provider = 'ruler'

      if @authorization_tag.save
        redirect_to ruler_area_tenant_authorization_tags_path(@tenant),
                    notice: t('ruler_area.authorization_tags.created')
      else
        @error_message = @authorization_tag.errors.full_messages.join(', ')
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @authorization_tag.update(authorization_tag_params)
        redirect_to ruler_area_tenant_authorization_tags_path(@tenant),
                    notice: t('ruler_area.authorization_tags.updated')
      else
        @error_message = @authorization_tag.errors.full_messages.join(', ')
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @authorization_tag.system?
        redirect_to ruler_area_tenant_authorization_tags_path(@tenant),
                    alert: t('ruler_area.authorization_tags.cannot_delete_system')
        return
      end

      if @authorization_tag.idp?
        redirect_to ruler_area_tenant_authorization_tags_path(@tenant),
                    alert: t('ruler_area.authorization_tags.cannot_delete_external')
        return
      end

      if @authorization_tag.destroy
        redirect_to ruler_area_tenant_authorization_tags_path(@tenant),
                    notice: t('ruler_area.authorization_tags.destroyed')
      else
        redirect_to ruler_area_tenant_authorization_tags_path(@tenant),
                    alert: @authorization_tag.errors.full_messages.join(', ')
      end
    end

    private

    def set_authorization_tag
      @authorization_tag = ContentAuthorizationTag.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to ruler_area_tenant_authorization_tags_path(@tenant),
                  alert: t('ruler_area.authorization_tags.not_found')
    end

    def authorization_tag_params
      params.require(:content_authorization_tag).permit(:name, :unique_id)
    end
  end
end
