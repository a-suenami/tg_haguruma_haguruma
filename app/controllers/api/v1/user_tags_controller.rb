# typed: true
# frozen_string_literal: true

# ==============================================================================
# app - controllers - api - v1 - user tags controller
# ==============================================================================
module Api
  module V1
    class UserTagsController < ApplicationController
      extend T::Sig

      sig { void }
      def index
        user = User.find(params[:user_id])
        tags = user.content_authorization_tags

        render json: tags.map { |tag| tag_as_json(tag) }
      end

      sig { void }
      def create
        user = User.find(params[:user_id])
        tag = ContentAuthorizationTag.find(params[:content_authorization_tag_id])

        user_tag = UserTag.new(user: user, content_authorization_tag: tag)

        if user_tag.save
          render json: tag_as_json(tag), status: :created
        else
          render json: { errors: user_tag.errors.full_messages }, status: :unprocessable_entity
        end
      end

      sig { void }
      def destroy
        user = User.find(params[:user_id])
        user_tag = UserTag.find_by!(user: user, content_authorization_tag_id: params[:id])
        user_tag.destroy!

        head :no_content
      end

      private

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
