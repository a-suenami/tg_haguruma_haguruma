# typed: strict
# frozen_string_literal: true

module AdminArea
  module Contents
    class SaveTextFieldService < BaseSaveFieldService
      extend T::Sig

      private

      sig { override.returns(String) }
      def expected_field_type
        'text'
      end

      sig { override.params(field: ContentEntry::Field).void }
      def save_field_value(field)
        if field.text
          field.text.update!(value: @value.to_s)
        else
          text = ContentEntry::FieldText.create!(value: @value.to_s)
          field.text = text
        end
        field.save!
      end
    end
  end
end
