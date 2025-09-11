# typed: true
# frozen_string_literal: true

module RulerArea
  class ApplicationController < ActionController::Base
    layout 'ruler_area/application'

    # TODO: Add Pagy when available
    # include Pagy::Backend

    # TODO: Add authentication when Ruler model is available
    # before_action :authenticate!
    # after_action :log_activity

    # def authenticate!
    #   redirect_to ruler_area_login_path unless signed_in?
    # end

    # def current_ruler
    #   @current_ruler ||= Ruler.find_by(id: session[:ruler_id])
    # end

    # def signed_in?
    #   current_ruler.present?
    # end

    private

    def set_tenant
      @tenant = Tenant.find(params[:tenant_id])
      RequestStore.store[:current_tenant] = @tenant.id
      Tenant.current
    end

    # TODO: Add activity logging when ActivityLog model is available
    # def log_activity
    #   should_log = request.method != 'GET' && response.status < 400
    #   return unless should_log

    #   parameter_filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    #   ActivityLogs::CreateService.new(
    #     path: T.cast(request.path, String),
    #     params: parameter_filter.filter(params),
    #     by_uuid: T.cast(current_ruler.id, String),
    #     by_email: T.cast(current_ruler.email, String),
    #   ).execute
    # rescue => e
    #   Sentry.capture_exception(e)
    # end
  end
end
