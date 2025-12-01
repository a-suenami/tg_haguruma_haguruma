# typed: true
# frozen_string_literal: true

# ==============================================================================
# app - controllers - api - v1 - content entry authorizations controller
# ==============================================================================
module Api
  module V1
    class ContentEntryAuthorizationsController < ApplicationController
      extend T::Sig

      sig { void }
      def index
        version = find_content_entry_version
        tags = version.content_authorization_tags

        render json: tags.map { |tag| tag_as_json(tag) }
      end

      sig { void }
      def create
        version = find_content_entry_version
        tag = ContentAuthorizationTag.find(params[:content_authorization_tag_id])

        authorization = ContentEntryAuthorization.new(
          content_entry_id: version.content_entry_id,
          version: version.version,
          content_authorization_tag: tag,
        )

        if authorization.save
          render json: tag_as_json(tag), status: :created
        else
          render json: { errors: authorization.errors.full_messages }, status: :unprocessable_entity
        end
      end

      sig { void }
      def destroy
        version = find_content_entry_version
        authorization = ContentEntryAuthorization.find_by!(
          content_entry_id: version.content_entry_id,
          version: version.version,
          content_authorization_tag_id: params[:id],
        )
        authorization.destroy!

        head :no_content
      end

      private

      sig { returns(ContentEntry::Version) }
      def find_content_entry_version
        ContentEntry::Version.find_by!(
          content_entry_id: params[:content_entry_id],
          version: params[:version_id],
        )
      end

      sig { params(tag: ContentAuthorizationTag).returns(T::Hash[Symbol, T.untyped]) }
      def tag_as_json(tag)
        {
          id: tag.id,
          name: tag.name,
          remote_id: tag.remote_id,
          created_at: tag.created_at,
          updated_at: tag.updated_at,
        }
      end
    end
  end
end
