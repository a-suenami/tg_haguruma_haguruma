# typed: true
# frozen_string_literal: true

# ==============================================================================
# app - controllers - api - v1 - content authorization tags controller
# ==============================================================================
module Api
  module V1
    class ContentAuthorizationTagsController < ApplicationController
      extend T::Sig

      sig { void }
      def index
        tags = ContentAuthorizationTag.all

        render json: tags.map { |tag| tag_as_json(tag) }
      end

      sig { void }
      def show
        tag = ContentAuthorizationTag.find(params[:id])

        render json: tag_as_json(tag)
      end

      sig { void }
      def create
        tag = ContentAuthorizationTag.new(tag_params)

        if tag.save
          render json: tag_as_json(tag), status: :created
        else
          render json: { errors: tag.errors.full_messages }, status: :unprocessable_entity
        end
      end

      sig { void }
      def update
        tag = ContentAuthorizationTag.find(params[:id])

        if tag.update(tag_params)
          render json: tag_as_json(tag)
        else
          render json: { errors: tag.errors.full_messages }, status: :unprocessable_entity
        end
      end

      sig { void }
      def destroy
        tag = ContentAuthorizationTag.find(params[:id])
        tag.destroy!

        head :no_content
      end

      private

      sig { returns(ActionController::Parameters) }
      def tag_params
        params.require(:content_authorization_tag).permit(:name, :remote_id)
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
