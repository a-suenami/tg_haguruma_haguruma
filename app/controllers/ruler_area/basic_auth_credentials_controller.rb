# typed: true
# frozen_string_literal: true

module RulerArea
  class BasicAuthCredentialsController < ApplicationController
    include RulerArea::TenantSettable

    before_action :set_tenant
    before_action :set_basic_auth
    before_action :set_credential, only: [:edit, :update, :destroy]

    def new
      @credential = @basic_auth.credentials.build
    end

    def edit; end

    def create
      @credential = @basic_auth.credentials.build(credential_params)
      if @credential.save
        redirect_to ruler_area_tenant_basic_auth_path(@tenant), notice: t('ruler_area.basic_auth_credentials.created')
      else
        render :new, status: :unprocessable_entity
      end
    end


    def update
      if @credential.update(credential_params)
        redirect_to ruler_area_tenant_basic_auth_path(@tenant), notice: t('ruler_area.basic_auth_credentials.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @credential.destroy
      redirect_to ruler_area_tenant_basic_auth_path(@tenant), notice: t('ruler_area.basic_auth_credentials.destroyed')
    end

    private

    def set_basic_auth
      @basic_auth = @tenant.basic_auth || @tenant.build_basic_auth
    end

    def set_credential
      @credential = @basic_auth.credentials.find(params[:id])
    end

    def credential_params
      params.require(:credential).permit(:username, :password, :description)
    end
  end
end
