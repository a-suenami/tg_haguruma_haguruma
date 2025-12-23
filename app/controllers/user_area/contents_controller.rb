# typed: true
# frozen_string_literal: true

module UserArea
  class ContentsController < ApplicationController
    extend T::Sig

    # GET /contents
    sig { void }
    def index
      @content_types = ContentType.all
    end

    # GET /contents/:id
    sig { void }
    def show
      @content_entry = ContentEntry.find(params[:id])
    end
  end
end
