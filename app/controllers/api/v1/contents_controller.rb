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

        # Filter by authorization: only return entries the user can access
        authorized_entries = content_entries.select do |entry|
          published_version = entry.versions.find(&:published?)
          next false unless published_version

          ContentAuthorizationQuery.new(user: current_user, content_entry_version: published_version).authorized?
        end

        render json: ContentEntriesSerializer.new(authorized_entries).as_json
      end

      sig { void }
      def show
        content_entry = UserQueries::ContentEntriesQuery.new.published.resolve_find(params[:id])
        published_version = content_entry.versions.find(&:published?)

        if published_version
          authorized = ContentAuthorizationQuery.new(user: current_user, content_entry_version: published_version).authorized?
          raise ContentAuthorizationQuery::ContentAuthorizationError unless authorized
        end

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
