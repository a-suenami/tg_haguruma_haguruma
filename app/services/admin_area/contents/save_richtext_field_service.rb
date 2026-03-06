# typed: strict
# frozen_string_literal: true

module AdminArea
  module Contents
    class SaveRichtextFieldService < BaseSaveFieldService
      extend T::Sig

      private

      sig { override.returns(String) }
      def expected_field_type
        'richtext'
      end

      sig { override.params(field: ContentEntry::Field).void }
      def save_field_value(field)
        # Parse JSON string to hash for storage
        richtext_value = if @value.is_a?(String)
          parsed = JSON.parse(@value)
          parsed.is_a?(Hash) ? parsed : nil
        else
          @value
        end

        return if richtext_value.blank?

        if field.richtext
          T.must(field.richtext).update!(value: richtext_value)
        else
          richtext = ContentEntry::FieldRichtext.create!(value: richtext_value)
          field.richtext = richtext
        end
        field.save!
      end
    end
  end
end
