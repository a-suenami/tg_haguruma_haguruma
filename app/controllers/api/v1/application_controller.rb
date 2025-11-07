# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - controllers - api - v1 - application controller
# ==============================================================================
module Api
  module V1
    class ApplicationController < ActionController::API
      extend T::Sig

      include Api::ExceptionRescuable
    end
  end
end
