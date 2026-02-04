# typed: true
# frozen_string_literal: true

module UserArea
  class ErrorsController < ApplicationController
    extend T::Sig

    # GET /*path (catch-all route for 404)
    sig { void }
    def not_found
      render 'user_area/errors/404', layout: false, status: :not_found
    end
  end
end
