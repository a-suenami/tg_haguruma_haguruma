# typed: true
# frozen_string_literal: true

# ==============================================================================
# app - controllers - api - v1 - contents controller
# ==============================================================================
module Api
  module V1
    class ContentsController < ApplicationController
      extend T::Sig

      sig { void }
      def index
        content_entries = UserQueries::ContentEntriesQuery.new
                            .by_content_type(params[:content_type_id])
                            .published
                            .resolve

        render json: ContentEntriesSerializer.new(content_entries).as_json
      end

      sig { void }
      def show
        content_entry = UserQueries::ContentEntriesQuery.new.published.resolve_find(params[:id])

        render json: ContentEntrySerializer.new(content_entry).as_json
      end
    end
  end
end
