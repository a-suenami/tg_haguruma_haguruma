# typed: strict
# frozen_string_literal: true

module AdminArea
  module Contents
    class SetAuthorizationTagsService < BaseService
      extend T::Sig

      class Result < T::Struct
        const :success, T::Boolean
        const :errors, T::Array[String]
      end

      sig do
        params(
          content_entry: ContentEntry,
          version: ContentEntry::Version,
          authorization_tag_ids: T::Array[String],
          is_public: T::Boolean,
        ).void
      end
      def initialize(content_entry:, version:, authorization_tag_ids:, is_public: true)
        @content_entry = content_entry
        @version = version
        @authorization_tag_ids = authorization_tag_ids
        @is_public = is_public
        @errors = T.let([], T::Array[String])
      end

      sig { returns(Result) }
      def call
        ActiveRecord::Base.transaction do
          update_is_public
          clear_existing_authorizations
          create_new_authorizations

          raise ActiveRecord::Rollback if @errors.any?
        end

        Result.new(success: @errors.empty?, errors: @errors)
      end

      private

      sig { void }
      def update_is_public
        @version.update!(is_public: @is_public)
      rescue ActiveRecord::RecordInvalid => e
        @errors << e.message
      end

      sig { void }
      def clear_existing_authorizations
        ContentEntryAuthorization.where(
          tenant_id: Tenant.current_id,
          content_entry_id: @content_entry.id,
          version: @version.version,
        ).destroy_all
      end

      sig { void }
      def create_new_authorizations
        @authorization_tag_ids.each do |tag_id|
          next if tag_id.blank?

          authorization = ContentEntryAuthorization.new(
            tenant_id: Tenant.current_id,
            content_entry_id: @content_entry.id,
            version: @version.version,
            content_authorization_tag_id: tag_id,
          )

          unless authorization.save
            @errors.concat(authorization.errors.full_messages)
          end
        end
      end
    end
  end
end
