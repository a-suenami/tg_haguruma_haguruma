# typed: strict
# frozen_string_literal: true

module AdminArea
  module Contents
    class SaveSelectFieldService < BaseSaveFieldService
      extend T::Sig

      private

      sig { override.returns(String) }
      def expected_field_type
        'select_field'
      end

      sig { override.params(field: ContentEntry::Field).void }
      def save_field_value(field)
        # value can be a single ID (dropdown/radio) or array of IDs (checkbox)
        option_ids = Array(@value).compact_blank.map(&:to_i)

        # Validate options belong to this select field
        valid_option_ids = @content_type_field.select&.options&.pluck(:id) || []
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
    end
  end
end
