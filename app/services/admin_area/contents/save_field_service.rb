# typed: strict
# frozen_string_literal: true

module AdminArea
  module Contents
    class SaveFieldService < BaseService
      extend T::Sig

      class Result < T::Struct
        const :success, T::Boolean
        const :field, T.nilable(ContentEntry::Field)
        const :errors, T::Array[String]
      end

      sig do
        params(
          content_type: ContentType,
          content_entry: ContentEntry,
          content_type_field: ContentType::Field,
          value: T.untyped,
        ).void
      end
      def initialize(content_type:, content_entry:, content_type_field:, value:)
        @content_type = content_type
        @content_entry = content_entry
        @content_type_field = content_type_field
        @value = value
        @errors = T.let([], T::Array[String])
      end

      sig { returns(Result) }
      def call
        ActiveRecord::Base.transaction do
          version = find_or_create_draft_version
          field = save_field(version)

          if @errors.empty?
            Result.new(success: true, field: field, errors: [])
          else
            raise ActiveRecord::Rollback
          end
        end

        if @errors.any?
          Result.new(success: false, field: nil, errors: @errors)
        else
          Result.new(success: true, field: @saved_field, errors: [])
        end
      end

      private

      sig { returns(ContentEntry::Version) }
      def find_or_create_draft_version
        existing_draft = ContentEntry::Version.find_by(
          tenant_id: Tenant.current_id,
          content_type_id: @content_type.id,
          content_entry_id: @content_entry.id,
          status: ContentEntry::Version::STATUSES[:draft],
        )

        return existing_draft if existing_draft

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
        )

        unless version.save
          @errors.concat(version.errors.full_messages)
        end

        version
      end

      sig { params(version: ContentEntry::Version).returns(T.nilable(ContentEntry::Field)) }
      def save_field(version)
        # Validate required field
        if @content_type_field.required && @value.blank?
          @errors << "#{@content_type_field.label}は必須です"
          return nil
        end

        # Find or create field record
        field = ContentEntry::Field.find_or_initialize_by(
          tenant_id: Tenant.current_id,
          content_type_id: @content_type.id,
          content_entry_id: @content_entry.id,
          version: version.version,
          content_type_field_id: @content_type_field.id,
        )

        field.field_type = @content_type_field.field_type

        case @content_type_field.field_type
        when 'text'
          save_text_field(field)
        when 'richtext'
          save_richtext_field(field)
        when 'media_asset'
          save_media_asset_field(field)
        end

        @saved_field = field
        field
      end

      sig { params(field: ContentEntry::Field).void }
      def save_text_field(field)
        if field.text
          field.text.update!(value: @value.to_s)
        else
          text = ContentEntry::FieldText.create!(value: @value.to_s)
          field.text = text
        end
        field.save!
      end

      sig { params(field: ContentEntry::Field).void }
      def save_richtext_field(field)
        richtext_value = @value.is_a?(String) ? { html: @value } : @value

        if field.richtext
          field.richtext.update!(value: richtext_value)
        else
          richtext = ContentEntry::FieldRichtext.create!(value: richtext_value)
          field.richtext = richtext
        end
        field.save!
      end

      sig { params(field: ContentEntry::Field).void }
      def save_media_asset_field(field)
        return if @value.blank?

        media_asset = MediaAsset.find_by(id: @value)
        return unless media_asset

        if field.media_asset
          field.media_asset.update!(
            media_type: media_asset.media_type,
            media_asset_id: media_asset.id,
          )
        else
          field_media_asset = ContentEntry::FieldMediaAsset.create!(
            tenant_id: Tenant.current_id,
            media_type: media_asset.media_type,
            media_asset_id: media_asset.id,
          )
          field.media_asset = field_media_asset
        end
        field.save!
      end
    end
  end
end
