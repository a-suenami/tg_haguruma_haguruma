# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - controllers - api - application controller
# ==============================================================================
module Api
  class ApplicationController < ActionController::API
    extend T::Sig

    include Api::ExceptionRescuable
  end
end
