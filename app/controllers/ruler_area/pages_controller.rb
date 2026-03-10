# typed: true
# frozen_string_literal: true

module RulerArea
  class PagesController < ApplicationController
    include RulerArea::TenantSettable

    before_action :set_tenant

    def index
      # Placeholder - Pages feature is not yet implemented
    end
  end
end
