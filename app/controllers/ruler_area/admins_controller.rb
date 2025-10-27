# typed: true
# frozen_string_literal: true

module RulerArea
  class AdminsController < ApplicationController
    # Temporary mock struct for UI development (will be replaced with Admin model)
    MockAdmin = Struct.new(:id, :email, :name, :tenant_id, :created_at, keyword_init: true)

    before_action :set_tenant
    before_action :set_admin, only: [:edit, :update, :destroy]

    def index
      @admins = mock_admins
    end

    def new
      @admin = MockAdmin.new(email: '', name: '', tenant_id: @tenant.id)
    end

    def edit; end

    def create
      # TODO: RulerArea::Admins::CreateService.new(admin_params).execute
      redirect_to ruler_area_tenant_admins_path(@tenant), notice: t('ruler_area.admins.created')
    end

    def update
      # TODO: RulerArea::Admins::UpdateService.new(admin_params).execute(@admin)
      redirect_to ruler_area_tenant_admins_path(@tenant), notice: t('ruler_area.admins.updated')
    end

    def destroy
      # TODO: RulerArea::Admins::DestroyService.new.execute(@admin)
      redirect_to ruler_area_tenant_admins_path(@tenant), notice: t('ruler_area.admins.destroyed')
    end

    private

    def set_tenant
      @tenant = Tenant.find(params[:tenant_id])
    end

    def set_admin
      @admin = mock_admins.find { |a| a.id == params[:id] }
      redirect_to ruler_area_tenant_admins_path(@tenant), alert: t('ruler_area.admins.not_found') unless @admin
    end

    def admin_params
      params.require(:admin).permit(:email, :name)
    end

    def mock_admins
      [
        MockAdmin.new(id: '1', email: 'admin1@example.com', name: 'サンプル管理者1', tenant_id: @tenant.id, created_at: 5.days.ago),
        MockAdmin.new(id: '2', email: 'admin2@example.com', name: 'サンプル管理者2', tenant_id: @tenant.id, created_at: 3.days.ago),
        MockAdmin.new(id: '3', email: 'admin3@example.com', name: 'サンプル管理者3', tenant_id: @tenant.id, created_at: 1.day.ago),
        MockAdmin.new(id: '4', email: 'admin4@example.com', name: 'サンプル管理者4', tenant_id: @tenant.id, created_at: Time.current),
      ]
    end
  end
end
