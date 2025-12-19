# typed: strict
# frozen_string_literal: true

module AdminArea
  module Contents
    class CreateDraftFromPublishedService < BaseService
      extend T::Sig

      class Result < T::Struct
        const :success, T::Boolean
        const :draft_version, T.nilable(ContentEntry::Version)
        const :errors, T::Array[String]
      end

      sig do
        params(
          content_type: ContentType,
          content_entry: ContentEntry,
          published_version: ContentEntry::Version,
        ).void
      end
      def initialize(content_type:, content_entry:, published_version:)
        @content_type = content_type
        @content_entry = content_entry
        @published_version = published_version
        @errors = T.let([], T::Array[String])
      end

      sig { returns(Result) }
      def call
        draft_version = T.let(nil, T.nilable(ContentEntry::Version))

        ActiveRecord::Base.transaction do
          draft_version = create_draft_version
          raise ActiveRecord::Rollback if @errors.any?

          copy_fields_to_draft(T.must(draft_version))
          raise ActiveRecord::Rollback if @errors.any?

          copy_authorization_tags(T.must(draft_version))
          raise ActiveRecord::Rollback if @errors.any?
        end

        if @errors.any?
          Result.new(success: false, draft_version: nil, errors: @errors)
        else
          Result.new(success: true, draft_version:, errors: [])
        end
      end

      private

      sig { returns(T.nilable(ContentEntry::Version)) }
      def create_draft_version
        max_version = ContentEntry::Version.where(
          tenant_id: Tenant.current_id,
          content_type_id: @content_type.id,
          content_entry_id: @content_entry.id,
        ).maximum(:version) || 0

        version = ContentEntry::Version.new(
          tenant_id: Tenant.current_id,
          content_type_id: @content_type.id,
          content_entry_id: @content_entry.id,
          version: max_version + 1,
          status: :draft,
          visibility: @published_version.visibility,
        )

        unless version.save
          @errors.concat(version.errors.full_messages)
          return nil
        end

        version
      end

      sig { params(draft_version: ContentEntry::Version).void }
      def copy_fields_to_draft(draft_version)
        @published_version.fields.each do |published_field|
          copy_field(published_field, draft_version)
        end
      end

      sig { params(published_field: ContentEntry::Field, draft_version: ContentEntry::Version).void }
      def copy_field(published_field, draft_version)
        new_field = ContentEntry::Field.new(
          tenant_id: Tenant.current_id,
          content_type_id: @content_type.id,
          content_entry_id: @content_entry.id,
          version: draft_version.version,
          content_type_field_id: published_field.content_type_field_id,
          field_type: published_field.field_type,
        )

        case published_field.field_type
        when 'text'
          copy_text_field(published_field, new_field)
        when 'richtext'
          copy_richtext_field(published_field, new_field)
        when 'media_asset'
          copy_media_asset_field(published_field, new_field)
        end

        unless new_field.save
          @errors.concat(new_field.errors.full_messages)
        end
      end

      sig { params(published_field: ContentEntry::Field, new_field: ContentEntry::Field).void }
      def copy_text_field(published_field, new_field)
        return unless published_field.text

        new_text = ContentEntry::FieldText.create!(value: T.must(published_field.text).value)
        new_field.text = new_text
      end

      sig { params(published_field: ContentEntry::Field, new_field: ContentEntry::Field).void }
      def copy_richtext_field(published_field, new_field)
        return unless published_field.richtext

        new_richtext = ContentEntry::FieldRichtext.create!(value: T.must(published_field.richtext).value)
        new_field.richtext = new_richtext
      end

      sig { params(published_field: ContentEntry::Field, new_field: ContentEntry::Field).void }
      def copy_media_asset_field(published_field, new_field)
        return unless published_field.media_asset

        # メディアアセットは同じものを参照するので、新しいFieldMediaAssetを作成して同じmedia_assetを参照
        new_media_asset = ContentEntry::FieldMediaAsset.create!(
          tenant_id: Tenant.current_id,
          media_asset_id: T.must(published_field.media_asset).media_asset_id,
          media_type: T.must(published_field.media_asset).media_type,
        )
        new_field.media_asset = new_media_asset
      end

      sig { params(draft_version: ContentEntry::Version).void }
      def copy_authorization_tags(draft_version)
        @published_version.content_authorization_tags.each do |tag|
          ContentEntryAuthorization.create!(
            tenant_id: Tenant.current_id,
            content_entry_id: @content_entry.id,
            version: draft_version.version,
            content_authorization_tag_id: tag.id,
          )
        end
      end
    end
  end
end
