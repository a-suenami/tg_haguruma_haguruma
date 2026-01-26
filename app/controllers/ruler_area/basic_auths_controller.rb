# typed: true
# frozen_string_literal: true

module RulerArea
  class BasicAuthsController < ApplicationController
    include RulerArea::TenantSettable

    before_action :set_tenant
    before_action :set_basic_auth

    def show; end

    def update
      if @basic_auth.update(basic_auth_params)
        redirect_to ruler_area_tenant_basic_auth_path(@tenant), notice: t('ruler_area.basic_auths.updated')
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def set_basic_auth
      @basic_auth = @tenant.basic_auth || @tenant.build_basic_auth
    end

    def basic_auth_params
      params.require(:basic_auth).permit(:enabled, :username, :password)
    end
  end
end
