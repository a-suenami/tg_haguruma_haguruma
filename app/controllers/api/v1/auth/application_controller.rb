# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - controllers - api - v1 - auth - application controller
# ==============================================================================
module Api
  module V1
    module Auth
      class ApplicationController < Api::V1::ApplicationController
        before_action :set_user_oauth_provider

        private

        sig { returns(T.nilable(OauthProvider)) }
        def set_user_oauth_provider
          @user_oauth_provider = T.let(
            Tenant.current&.oauth_providers&.first,
            T.nilable(OauthProvider),
          )
        end
      end
    end
  end
end
