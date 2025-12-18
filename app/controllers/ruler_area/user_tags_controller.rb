# typed: true
# frozen_string_literal: true

module RulerArea
  class UserTagsController < ApplicationController
    include RulerArea::TenantSettable

    before_action :set_tenant
    before_action :set_user
    before_action :set_user_tag, only: [:destroy]

    def create
      @authorization_tag = ContentAuthorizationTag.find(params[:content_authorization_tag_id])
      @user_tag = @user.user_tags.build(content_authorization_tag: @authorization_tag)

      if @user_tag.save
        redirect_to ruler_area_tenant_user_path(@tenant, @user), notice: t('ruler_area.user_tags.added')
      else
        redirect_to ruler_area_tenant_user_path(@tenant, @user), alert: @user_tag.errors.full_messages.join(', ')
      end
    end

    def destroy
      if @user_tag.destroy
        redirect_to ruler_area_tenant_user_path(@tenant, @user), notice: t('ruler_area.user_tags.removed')
      else
        redirect_to ruler_area_tenant_user_path(@tenant, @user), alert: @user_tag.errors.full_messages.join(', ')
      end
    end

    private

    def set_user
      @user = User.find(params[:user_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to ruler_area_tenant_users_path(@tenant), alert: t('ruler_area.users.not_found')
    end

    def set_user_tag
      @user_tag = @user.user_tags.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to ruler_area_tenant_user_path(@tenant, @user), alert: t('ruler_area.user_tags.not_found')
    end
  end
end
