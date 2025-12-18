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
        preview_mode = valid_preview_token?

        content_entry = if preview_mode
                          find_content_entry_for_preview
                        else
                          UserQueries::ContentEntriesQuery.new.published.resolve_find(params[:id])
                        end

        unless preview_mode || UserQueries::ContentEntriesQuery.authorized?(content_entry, user: current_user)
          raise UserQueries::ContentEntriesQuery::ContentAuthorizationError
        end

        render json: ContentEntrySerializer.new(content_entry, preview_mode:).as_json
      end

      private

      # Returns the current authenticated user, or nil if not authenticated.
      # TODO: Implement actual user authentication when available.
      sig { returns(T.nilable(User)) }
      def current_user
        nil
      end

      sig { returns(T::Boolean) }
      def valid_preview_token?
        token = params[:preview_token]
        return false if token.blank?

        begin
          payload = Preview::TokenService.verify(token)
          payload[:content_entry_id] == params[:id] && payload[:tenant_id] == Tenant.current_id
        rescue Preview::TokenService::InvalidTokenError, Preview::TokenService::ExpiredTokenError
          false
        end
      end

      sig { returns(ContentEntry) }
      def find_content_entry_for_preview
        ContentEntry.includes(:content_type, versions: { fields: [:content_type_field, :text, :richtext, :media_asset] })
                    .find(params[:id])
      end
    end
  end
end
