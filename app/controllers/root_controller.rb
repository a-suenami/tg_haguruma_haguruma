# typed: strict
# frozen_string_literal: true

class RootController < ApplicationController
  extend T::Sig

  skip_before_action :verify_authenticity_token, raise: false

  sig { void }
  def index
    subdomain = request.subdomain

    if subdomain&.start_with?('ruler')
      redirect_to '/ruler', allow_other_host: true
    elsif subdomain&.start_with?('admin')
      redirect_to '/admin', allow_other_host: true
    else
      # Default fallback - could redirect to a landing page or show an error
      redirect_to '/ruler', allow_other_host: true
    end
  end
end
