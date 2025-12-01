# typed: true
# frozen_string_literal: true

module RulerArea
  class TenantsController < ApplicationController
    before_action :set_tenant, only: [:show, :edit, :update, :admin_area]

    def index
      # TODO: Add pagy when available
      # @pagy, @tenants = pagy Tenant.preload(:config).order(id: :asc)
      @tenants = Tenant.order(id: :asc)
    end

    def show; end

    def new
      @tenant = Tenant.new
    end

    def edit; end

    def create
      # TODO: Use service when available
      # @tenant = RulerArea::Tenants::CreateService.new(tenant_params).execute
      @tenant = Tenant.new(tenant_params)

      if @tenant.save
        redirect_to ruler_area_tenant_path(@tenant), notice: t('helpers.messages.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      # TODO: Use service when available
      # @tenant = RulerArea::Tenants::UpdateService.new(tenant_params).execute(@tenant)

      if @tenant.update(tenant_params)
        redirect_to ruler_area_tenant_path(@tenant), notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def admin_area
      # TODO: Enable when Admin model is available
      # Admin.find_or_create_by(tenant_id: @tenant.id, auth0_account_id: current_ruler.auth0_account_id)

      url = if Rails.env.development?
        "http://#{@tenant.id}.#{request.host}:#{request.port}/admin"
      else
        "https://#{@tenant.id}.#{Settings.domains.admin}/admin"
      end

      redirect_to url, allow_other_host: true
    end

    private

    def set_tenant
      @tenant = Tenant.find(params[:id])
      Tenant.current_id = @tenant.id
    end

    def tenant_params
      T.cast(params.require(:tenant), ActionController::Parameters).permit(
        :id,
        :name,
        :user_page_domain,
        # TODO: Add config_attributes when Tenant::Config is available
        # config_attributes: [
        #   :id,
        #   :push_user_mail_event_enabled,
        #   :phone_number_verification_enabled,
        #   :verified_phone_number_change_allowed,
        # ],
      )
    end
  end
end
