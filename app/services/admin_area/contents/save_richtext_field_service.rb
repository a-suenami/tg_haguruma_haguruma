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
        richtext_value = @value.is_a?(String) ? { html: @value } : @value

        if field.richtext
          field.richtext.update!(value: richtext_value)
        else
          richtext = ContentEntry::FieldRichtext.create!(value: richtext_value)
          field.richtext = richtext
        end
        field.save!
      end
    end
  end
end
