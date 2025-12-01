# typed: true
# frozen_string_literal: true

module RulerArea
  class RulersController < ApplicationController
    before_action :set_ruler, only: [:edit, :update, :destroy]

    def index
      @rulers = Ruler.order(created_at: :desc)
    end

    def new
      @ruler = Ruler.new
    end

    def edit; end

    def create
      result = RulerArea::Rulers::CreateService.new(
        email: ruler_params[:email],
        name: ruler_params[:name],
      ).execute

      if result.is_a?(Mangrove::Result::Ok)
        redirect_to ruler_area_rulers_path, notice: t('ruler_area.rulers.created')
      else
        # Ruler doesn't have email column, only name
        @ruler = Ruler.new(name: ruler_params[:name])
        # Store email in instance variable for form display
        @ruler.instance_variable_set(:@_form_email, ruler_params[:email])
        @error_message = result.err_inner.join(', ')  # Store in instance variable for inline display
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @ruler.update(name: ruler_params[:name])
        redirect_to ruler_area_rulers_path, notice: t('ruler_area.rulers.updated')
      else
        @error_message = @ruler.errors.full_messages.join(', ')
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @ruler.destroy
        redirect_to ruler_area_rulers_path, notice: t('ruler_area.rulers.destroyed')
      else
        redirect_to ruler_area_rulers_path, alert: @ruler.errors.full_messages.join(', ')
      end
    end

    private

    def set_ruler
      @ruler = Ruler.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to ruler_area_rulers_path, alert: t('ruler_area.rulers.not_found')
    end

    def ruler_params
      params.require(:ruler).permit(:email, :name)
    end
  end
end
