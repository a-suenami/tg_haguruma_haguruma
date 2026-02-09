# typed: true
# frozen_string_literal: true

module UserArea
  class ErrorsController < ApplicationController
    extend T::Sig

    layout 'user_area/error'

    # GET /*path (catch-all route for 404)
    sig { void }
    def not_found
      render 'user_area/errors/404', status: :not_found, formats: [:html]
    end

    # GET /auth/error - OAuth flow cancelled or failed
    sig { void }
    def oauth_cancelled
      render 'user_area/errors/oauth_cancelled', formats: [:html]
    end
  end
end
