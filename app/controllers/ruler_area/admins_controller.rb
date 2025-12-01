# typed: true
# frozen_string_literal: true

module RulerArea
  class AdminsController < ApplicationController
    before_action :set_tenant
    before_action :set_admin, only: [:edit, :update, :destroy]

    def index
      @admins = @tenant.admins.order(created_at: :desc)
    end

    def new
      @admin = Admin.new(tenant: @tenant)
    end

    def edit; end

    def create
      result = RulerArea::Admins::CreateService.new(
        tenant: @tenant,
        email: admin_params[:email],
        name: admin_params[:name],
      ).execute

      if result.is_a?(Mangrove::Result::Ok)
        redirect_to ruler_area_tenant_admins_path(@tenant), notice: t('ruler_area.admins.created')
      else
        # Admin doesn't have email column, only name
        @admin = Admin.new(name: admin_params[:name], tenant: @tenant)
        # Store email in instance variable for form display
        @admin.instance_variable_set(:@_form_email, admin_params[:email])
        @error_message = result.err_inner.join(', ')  # Store in instance variable for inline display
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @admin.update(name: admin_params[:name])
        redirect_to ruler_area_tenant_admins_path(@tenant), notice: t('ruler_area.admins.updated')
      else
        @error_message = @admin.errors.full_messages.join(', ')
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @admin.destroy
        redirect_to ruler_area_tenant_admins_path(@tenant), notice: t('ruler_area.admins.destroyed')
      else
        redirect_to ruler_area_tenant_admins_path(@tenant), alert: @admin.errors.full_messages.join(', ')
      end
    end

    private

    def set_admin
      @admin = @tenant.admins.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to ruler_area_tenant_admins_path(@tenant), alert: t('ruler_area.admins.not_found')
    end

    def admin_params
      params.require(:admin).permit(:email, :name)
    end
  end
end
