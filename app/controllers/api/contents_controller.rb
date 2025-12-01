# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - controllers - api - contents controller
# ==============================================================================
module Api
  class ContentsController < ApplicationController
    extend T::Sig

    sig { void }
    def index
      content_entries = ContentEntriesQuery.new(content_type_id: params[:content_type_id]).call

      render json: ContentEntriesSerializer.new(content_entries).as_json
    end

    sig { void }
    def show
      content_entry = ContentEntry.find(params[:id])

      render json: ContentEntrySerializer.new(content_entry).as_json
    end
  end
end
