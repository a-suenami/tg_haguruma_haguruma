# typed: true
# frozen_string_literal: true

class AdminArea::ApplicationController < ApplicationController
  extend T::Sig

  layout 'admin_area/application'

  private

  sig { returns(T::Boolean) }
  def mobile_request?
    request.user_agent&.match?(/Mobile|Android|iPhone|iPad/i) || false
  end
end
