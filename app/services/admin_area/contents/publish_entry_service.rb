# typed: strict
# frozen_string_literal: true

module AdminArea
  module Contents
    class PublishEntryService < BaseService
      extend T::Sig

      class Result < T::Struct
        const :success, T::Boolean
        const :version, T.nilable(ContentEntry::Version)
        const :errors, T::Array[String]
      end

      sig { params(content_type: ContentType, content_entry: ContentEntry).void }
      def initialize(content_type:, content_entry:)
        @content_type = content_type
        @content_entry = content_entry
        @errors = T.let([], T::Array[String])
      end

      sig { returns(Result) }
      def call
        ActiveRecord::Base.transaction do
          # Find draft version to publish
          draft_version = find_draft_version
          unless draft_version
            @errors << '公開する下書きが見つかりません'
            raise ActiveRecord::Rollback
          end

          # Unpublish current published version if exists
          unpublish_current_version

          # Publish the draft version
          publish_version(draft_version)

          if @errors.empty?
            Result.new(success: true, version: draft_version, errors: [])
          else
            raise ActiveRecord::Rollback
          end
        end

        if @errors.any?
          Result.new(success: false, version: nil, errors: @errors)
        else
          Result.new(success: true, version: @published_version, errors: [])
        end
      end

      private

      sig { returns(T.nilable(ContentEntry::Version)) }
      def find_draft_version
        ContentEntry::Version.find_by(
          tenant_id: Tenant.current_id,
          content_type_id: @content_type.id,
          content_entry_id: @content_entry.id,
          status: ContentEntry::Version::STATUSES[:draft],
        )
      end

      sig { void }
      def unpublish_current_version
        current_published = ContentEntry::Version.find_by(
          tenant_id: Tenant.current_id,
          content_type_id: @content_type.id,
          content_entry_id: @content_entry.id,
          status: ContentEntry::Version::STATUSES[:published],
        )

        return unless current_published

        current_published.update!(
          status: :unpublished,
          unpublished_at: Time.current,
        )
      end

      sig { params(version: ContentEntry::Version).void }
      def publish_version(version)
        version.update!(
          status: :published,
          published_at: Time.current,
        )
        assign_system_authorization_tag(version)
        sync_media_asset_visibility(version)
        @published_version = T.let(version, T.nilable(ContentEntry::Version))
      end

      sig { params(version: ContentEntry::Version).void }
      def sync_media_asset_visibility(version)
        ::MediaAssets::VisibilitySyncService.new(version:).call
      end

      sig { params(version: ContentEntry::Version).void }
      def assign_system_authorization_tag(version)
        tag = case version.visibility
              when 'public'
                ContentAuthorizationTag.public_tag
              when 'authenticated'
                ContentAuthorizationTag.member_tag
              else
                return
        end

        ContentEntryAuthorization.find_or_create_by!(
          content_entry_id: version.content_entry_id,
          version: version.version,
          content_authorization_tag: tag,
        )
      end
    end
  end
end
