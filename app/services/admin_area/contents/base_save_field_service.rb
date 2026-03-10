# typed: strict
# frozen_string_literal: true

module AdminArea
  module Contents
    class BaseSaveFieldService < BaseService
      extend T::Sig
      extend T::Helpers
      abstract!

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
        @saved_field = T.let(nil, T.nilable(ContentEntry::Field))
      end

      sig { returns(Result) }
      def call
        ActiveRecord::Base.transaction do
          version = find_draft_version
          unless version
            @errors << '保存対象の下書きが見つかりません'
            raise ActiveRecord::Rollback
          end

          save_field(version)
          raise ActiveRecord::Rollback if @errors.any?
        end

        if @errors.any?
          Result.new(success: false, field: nil, errors: @errors)
        else
          Result.new(success: true, field: @saved_field, errors: [])
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

        field.field_type = expected_field_type

        save_field_value(field)

        @saved_field = field
        field
      end

      sig { abstract.returns(String) }
      def expected_field_type; end

      sig { abstract.params(field: ContentEntry::Field).void }
      def save_field_value(field); end
    end
  end
end
