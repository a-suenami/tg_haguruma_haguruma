# typed: true
# frozen_string_literal: true

module UserArea
  class TopController < ApplicationController
    extend T::Sig

    # GET /
    sig { void }
    def index
      # Landing page for the user area
    end
  end
end
