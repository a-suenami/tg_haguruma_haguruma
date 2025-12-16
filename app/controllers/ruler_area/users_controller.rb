# typed: true
# frozen_string_literal: true

module RulerArea
  class UsersController < ApplicationController
    include RulerArea::TenantSettable

    before_action :set_tenant
    before_action :set_user, only: [:show, :destroy]

    def index
      @users = User.includes(:oauth_provider, :session_tokens, :user_tags).order(created_at: :desc)
    end

    def show
      @authorization_tags = ContentAuthorizationTag.order(:name)
      @available_tags = @authorization_tags.where.not(id: @user.content_authorization_tag_ids)
    end

    def new
      @user = User.new
      @oauth_providers = @tenant.oauth_provider ? [T.must(@tenant.oauth_provider)] : []
    end

    def create
      @user = User.new(user_params)
      @user.uid = SecureRandom.uuid if @user.uid.blank?
      @user.oauth_provider = @tenant.oauth_provider

      if @user.save
        redirect_to ruler_area_tenant_user_path(@tenant, @user), notice: t('ruler_area.users.created')
      else
        @oauth_providers = @tenant.oauth_provider ? [T.must(@tenant.oauth_provider)] : []
        @error_message = @user.errors.full_messages.join(', ')
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      if @user.last_authenticated_at.present?
        redirect_to ruler_area_tenant_user_path(@tenant, @user),
                    alert: t('ruler_area.users.cannot_delete_authenticated')
        return
      end

      if @user.destroy
        redirect_to ruler_area_tenant_users_path(@tenant), notice: t('ruler_area.users.destroyed')
      else
        redirect_to ruler_area_tenant_user_path(@tenant, @user), alert: @user.errors.full_messages.join(', ')
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to ruler_area_tenant_users_path(@tenant), alert: t('ruler_area.users.not_found')
    end

    def user_params
      params.require(:user).permit(:uid)
    end
  end
end
