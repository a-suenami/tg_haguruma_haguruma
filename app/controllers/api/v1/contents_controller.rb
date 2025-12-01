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
                            .authorized_for(current_user)
                            .resolve

        render json: ContentEntriesSerializer.new(content_entries).as_json
      end

      sig { void }
      def show
        query = UserQueries::ContentEntriesQuery.new.published.authorized_for(current_user)
        content_entry = query.resolve_find(params[:id])

        query.authorize!(content_entry)

        render json: ContentEntrySerializer.new(content_entry).as_json
      end

      private

      # Returns the current authenticated user, or nil if not authenticated.
      # TODO: Implement actual user authentication when available.
      sig { returns(T.nilable(User)) }
      def current_user
        nil
      end
    end
  end
end
