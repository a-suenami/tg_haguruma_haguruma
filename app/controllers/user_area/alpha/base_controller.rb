# typed: true
# frozen_string_literal: true

module UserArea
  module Alpha
    class BaseController < UserArea::ApplicationController
      extend T::Sig

      layout 'user_area/alpha/application'

      before_action :require_tenant_theme!

      private

      sig { void }
      def require_tenant_theme!
        return if current_tenant&.theme.present?

        raise ActionController::RoutingError.new('Tenant theme not configured')
      end
    end
  end
end
