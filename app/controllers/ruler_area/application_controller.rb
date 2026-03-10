# typed: true
# frozen_string_literal: true

module RulerArea
  class ApplicationController < ActionController::Base
    layout 'ruler_area/application'

    # TODO: Add Pagy when available
    # include Pagy::Backend

    before_action :authenticate!
    # after_action :log_activity

    helper_method :current_ruler, :ruler_signed_in?

    def authenticate!
      redirect_to ruler_area_login_path unless ruler_signed_in?
    end

    def current_ruler
      return @current_ruler if defined?(@current_ruler)

      @current_ruler = Ruler.includes(:auth0_account).find_by(id: session[:ruler_id]) if session[:ruler_id]
    end

    def ruler_signed_in?
      current_ruler.present?
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
