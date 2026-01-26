# typed: false
# frozen_string_literal: true

module RulerArea
  class CustomVariablesController < ApplicationController
    include RulerArea::TenantSettable

    before_action :set_tenant
    before_action :set_custom_variable, only: %i[edit update destroy edit_value update_value]

    def index
      @custom_variables = SiteCustomVariable.active.order(:created_at)
    end

    def new
      @custom_variable = SiteCustomVariable.new
    end

    def edit; end

    def create
      @custom_variable = SiteCustomVariable.new(custom_variable_create_params)
      if @custom_variable.save
        redirect_to ruler_area_tenant_custom_variables_path(@tenant), notice: t('ruler_area.custom_variables.created')
      else
        render :new, status: :unprocessable_entity
      end
    end


    def update
      if @custom_variable.update(custom_variable_update_params)
        redirect_to ruler_area_tenant_custom_variables_path(@tenant), notice: t('ruler_area.custom_variables.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @custom_variable.archive!
      redirect_to ruler_area_tenant_custom_variables_path(@tenant), notice: t('ruler_area.custom_variables.archived')
    end

    def edit_value; end

    def update_value
      @custom_variable.value = params.dig(:site_custom_variable, :value)
      if @custom_variable.save
        redirect_to ruler_area_tenant_custom_variables_path(@tenant), notice: t('ruler_area.custom_variables.value_updated')
      else
        render :edit_value, status: :unprocessable_entity
      end
    end

    private

    def set_custom_variable
      @custom_variable = SiteCustomVariable.find(params[:id])
    end

    def custom_variable_create_params
      params.require(:site_custom_variable).permit(:unique_name, :variable_type, :description, :boolean_value, :datetime_value, :text_value)
    end

    def custom_variable_update_params
      params.require(:site_custom_variable).permit(:description)
    end
  end
end
