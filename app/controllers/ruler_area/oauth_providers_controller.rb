# typed: true
# frozen_string_literal: true

module RulerArea
  class OauthProvidersController < ApplicationController
    include RulerArea::TenantSettable

    before_action :set_tenant
    before_action :set_oauth_provider, only: [:edit, :update, :destroy]

    def index
      @oauth_provider = @tenant.oauth_provider
    end

    def new
      @oauth_provider = @tenant.build_oauth_provider
    end

    def edit; end

    def create
      @oauth_provider = @tenant.build_oauth_provider(oauth_provider_params)

      if @oauth_provider.save
        redirect_to ruler_area_tenant_oauth_providers_path(@tenant), notice: t('ruler_area.oauth_providers.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @oauth_provider.update(oauth_provider_params)
        redirect_to ruler_area_tenant_oauth_providers_path(@tenant), notice: t('ruler_area.oauth_providers.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @oauth_provider.destroy
      redirect_to ruler_area_tenant_oauth_providers_path(@tenant), notice: t('ruler_area.oauth_providers.destroyed')
    end

    private

    def set_oauth_provider
      @oauth_provider = @tenant.oauth_provider
      redirect_to ruler_area_tenant_oauth_providers_path(@tenant), alert: t('ruler_area.oauth_providers.not_found') unless @oauth_provider
    end

    def oauth_provider_params
      permitted = params.require(:oauth_provider).permit(
        :kind,
        :client_id,
        :client_secret,
        :endpoint_base,
        :scopes,
        :keypath_uid,
        :session_expires_in,
      )
      permitted.delete(:client_secret) if permitted[:client_secret].blank?
      permitted
    end
  end
end
