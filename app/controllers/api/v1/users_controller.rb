# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - controllers - api - v1 - users controller
# ==============================================================================
module Api
  module V1
    class UsersController < ApplicationController
      extend T::Sig

      before_action :require_authentication!

      # GET /api/v1/users/me
      sig { void }
      def me
        user = T.must(current_user)
        session_token = T.must(current_session_token)
        last_authenticated = user.last_authenticated_at || session_token.created_at

        render json: {
          id: user.id,
          uid: user.uid,
          last_authenticated_at: last_authenticated.iso8601,
          authorization_tags: user.content_authorization_tags.map do |tag|
            {
              id: tag.id,
              name: tag.name,
            }
          end,
          registered_at: user.created_at.iso8601,
        }
      end
    end
  end
end
