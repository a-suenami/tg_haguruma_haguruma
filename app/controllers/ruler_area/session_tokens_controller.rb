# typed: true
# frozen_string_literal: true

module RulerArea
  class SessionTokensController < ApplicationController
    include RulerArea::TenantSettable

    EXPIRATION_OPTIONS = {
      '30' => 30.days.to_i,
      '60' => 60.days.to_i,
      '90' => 90.days.to_i,
      '365' => 365.days.to_i,
    }.freeze

    before_action :set_tenant
    before_action :set_user
    before_action :set_session_token, only: [:destroy]

    def index
      @session_tokens = @user.session_tokens.order(created_at: :desc)
    end

    def create
      expires_in = EXPIRATION_OPTIONS[params[:expires_in]] || 90.days.to_i

      @session_token = Auth::Tokens::IssueService.new.execute(user: @user, expires_in:)

      if @session_token.persisted?
        flash[:notice] = t('ruler_area.session_tokens.created')
        flash[:new_token] = @session_token.id
        redirect_to ruler_area_tenant_user_path(@tenant, @user)
      else
        redirect_to ruler_area_tenant_user_path(@tenant, @user), alert: t('ruler_area.session_tokens.create_failed')
      end
    end

    def destroy
      if @session_token.destroy
        redirect_to ruler_area_tenant_user_path(@tenant, @user), notice: t('ruler_area.session_tokens.revoked')
      else
        redirect_to ruler_area_tenant_user_path(@tenant, @user), alert: @session_token.errors.full_messages.join(', ')
      end
    end

    private

    def set_user
      @user = User.find(params[:user_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to ruler_area_tenant_users_path(@tenant), alert: t('ruler_area.users.not_found')
    end

    def set_session_token
      @session_token = @user.session_tokens.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to ruler_area_tenant_user_path(@tenant, @user), alert: t('ruler_area.session_tokens.not_found')
    end
  end
end
