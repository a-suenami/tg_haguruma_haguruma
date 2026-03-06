# typed: strict
# frozen_string_literal: true

module AdminArea
  module Contents
    class SaveEntryService < BaseService
      extend T::Sig

      class Result < T::Struct
        const :success, T::Boolean
        const :content_entry, T.nilable(ContentEntry)
        const :version, T.nilable(ContentEntry::Version)
        const :errors, T::Array[String]
      end

      sig do
        params(
          content_type: ContentType,
          content_entry: T.nilable(ContentEntry),
          fields_params: T::Hash[String, T.untyped],
          authorization_tag_ids: T::Array[String],
          visibility: String,
          custom_published_at: T.nilable(Time),
        ).void
      end
      def initialize(content_type:, content_entry: nil, fields_params: {}, authorization_tag_ids: [], visibility: 'public', custom_published_at: nil)
        @content_type = content_type
        @content_entry = content_entry
        @fields_params = fields_params
        @authorization_tag_ids = authorization_tag_ids
        @visibility = visibility
        @custom_published_at = custom_published_at
        @errors = T.let([], T::Array[String])
      end

      sig { returns(Result) }
      def call
        ActiveRecord::Base.transaction do
          entry = create_or_find_entry
          version = create_or_update_draft_version(entry)
          save_field_values(entry, version)
          save_authorization_tags(entry, version)

          if @errors.empty?
            Result.new(success: true, content_entry: entry, version:, errors: [])
          else
            raise ActiveRecord::Rollback
          end
        end

        if @errors.any?
          Result.new(success: false, content_entry: @content_entry, version: nil, errors: @errors)
        else
          Result.new(success: true, content_entry: @content_entry, version: @saved_version, errors: [])
        end
      end

      private

      sig { returns(ContentEntry) }
      def create_or_find_entry
        if @content_entry&.persisted?
          @content_entry
        else
          entry = @content_type.content_entries.build(
            tenant_id: Tenant.current_id,
          )
          unless entry.save
            @errors.concat(entry.errors.full_messages)
          end
          @content_entry = entry
          entry
        end
      end

      sig { params(entry: ContentEntry).returns(ContentEntry::Version) }
      def create_or_update_draft_version(entry)
        # Find existing draft version or create new one
        existing_draft = ContentEntry::Version.find_by(
          tenant_id: Tenant.current_id,
          content_type_id: @content_type.id,
          content_entry_id: entry.id,
          status: ContentEntry::Version::STATUSES[:draft],
        )

        if existing_draft
          update_attrs = { visibility: @visibility }
          update_attrs[:custom_published_at] = @custom_published_at if @custom_published_at
          existing_draft.update!(update_attrs)
          @saved_version = T.let(existing_draft, T.nilable(ContentEntry::Version))
          existing_draft
        else
          # Get next version number
          max_version = ContentEntry::Version.where(
            tenant_id: Tenant.current_id,
            content_type_id: @content_type.id,
            content_entry_id: entry.id,
          ).maximum(:version) || 0

          version = ContentEntry::Version.new(
            tenant_id: Tenant.current_id,
            content_type_id: @content_type.id,
            content_entry_id: entry.id,
            version: max_version + 1,
            status: :draft,
            visibility: @visibility,
            custom_published_at: @custom_published_at,
          )

          unless version.save
            @errors.concat(version.errors.full_messages)
          end
          @saved_version = T.let(version, T.nilable(ContentEntry::Version))
          version
        end
      end

      sig { params(entry: ContentEntry, version: ContentEntry::Version).void }
      def save_field_values(entry, version)
        @content_type.fields.each do |content_type_field|
          field_value = @fields_params[content_type_field.api_identifier]
          next if field_value.blank? && !content_type_field.required

          if content_type_field.required && field_value.blank?
            @errors << "#{content_type_field.label}は必須です"
            next
          end

          save_field(entry, version, content_type_field, field_value)
        end
      end

      sig { params(entry: ContentEntry, version: ContentEntry::Version, content_type_field: ContentType::Field, value: T.untyped).void }
      def save_field(entry, version, content_type_field, value)
        # Find or create field record
        field = ContentEntry::Field.find_or_initialize_by(
          tenant_id: Tenant.current_id,
          content_type_id: @content_type.id,
          content_entry_id: entry.id,
          version: version.version,
          content_type_field_id: content_type_field.id,
        )

        field.field_type = content_type_field.field_type

        case content_type_field.field_type
        when 'text'
          save_text_field(field, value)
        when 'richtext'
          save_richtext_field(field, value)
        when 'media_asset'
          save_media_asset_field(field, value)
        when 'select_field'
          save_select_field(field, content_type_field, value)
        end
      end

      sig { params(field: ContentEntry::Field, value: T.untyped).void }
      def save_text_field(field, value)
        if field.text
          T.must(field.text).update!(value: value.to_s)
        else
          text = ContentEntry::FieldText.create!(value: value.to_s)
          field.text = text
        end
        field.save!
      end

      sig { params(field: ContentEntry::Field, value: T.untyped).void }
      def save_richtext_field(field, value)
        richtext_value = parse_richtext_value(value)

        return if richtext_value.blank?

        if field.richtext
          T.must(field.richtext).update!(value: richtext_value)
        else
          richtext = ContentEntry::FieldRichtext.create!(value: richtext_value)
          field.richtext = richtext
        end
        field.save!
      end

      sig { params(field: ContentEntry::Field, value: T.untyped).void }
      def save_media_asset_field(field, value)
        return if value.blank?

        media_asset = MediaAsset.find_by(id: value)
        return unless media_asset

        if field.media_asset
          T.must(field.media_asset).update!(
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

      sig { params(field: ContentEntry::Field, content_type_field: ContentType::Field, value: T.untyped).void }
      def save_select_field(field, content_type_field, value)
        # value can be a single ID (dropdown/radio) or array of IDs (checkbox)
        option_ids = Array(value).compact_blank.map(&:to_i)

        # Validate options belong to this select field
        valid_option_ids = content_type_field.select&.options&.pluck(:id) || []
        option_ids &= valid_option_ids

        if field.select
          T.must(field.select).selected_option_ids = option_ids
          T.must(field.select).save!
        else
          field_select = ContentEntry::FieldSelect.create!(tenant_id: Tenant.current_id)
          field_select.selected_option_ids = option_ids
          field_select.save!
          field.select = field_select
        end
        field.save!
      end

      sig { params(value: T.untyped).returns(T.nilable(T::Hash[String, T.untyped])) }
      def parse_richtext_value(value)
        if value.is_a?(String)
          begin
            parsed = JSON.parse(value)
            parsed.is_a?(Hash) ? parsed : nil
          rescue JSON::ParserError
            nil
          end
        else
          value.is_a?(Hash) ? value : nil
        end
      end

      sig { params(entry: ContentEntry, version: ContentEntry::Version).void }
      def save_authorization_tags(entry, version)
        result = SetAuthorizationTagsService.new(
          content_entry: entry,
          version:,
          authorization_tag_ids: @authorization_tag_ids,
          visibility: @visibility,
        ).call

        @errors.concat(result.errors) unless result.success
      end
    end
  end
end
