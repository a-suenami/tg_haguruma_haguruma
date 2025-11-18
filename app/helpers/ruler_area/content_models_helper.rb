# typed: true
# frozen_string_literal: true

module RulerArea
  module ContentModelsHelper
    extend T::Sig

    sig { params(target: T.untyped).returns(T::Array[String]) }
    def format_form_errors(target)
      all_errors = []
      processed_field_errors = Set.new

      target.errors.each do |error|
        if error.attribute.to_s.start_with?('fields.')
          # Field errors - process all fields with api_identifier errors
          if error.attribute.to_s.include?('api_identifier')
            target.fields.each do |field|
              next unless field.errors[:api_identifier].any?
              next if processed_field_errors.include?(field.object_id)

              processed_field_errors.add(field.object_id)
              all_errors << format_field_error(field, error)
            end
          else
            all_errors << error.full_message
          end
        elsif error.attribute == :unique_name
          # Content type identifier error
          all_errors << format_content_type_identifier_error(target, error)
        else
          all_errors << error.full_message
        end
      end

      all_errors
    end

    private

    sig { params(field: T.untyped, error: T.untyped).returns(String) }
    def format_field_error(field, error)
      conflicting = field.conflicting_field
      identifier_label = I18n.t('ruler_area.content_models.field_identifier_label')
      field_name_prefix = I18n.t('ruler_area.content_models.field_label_prefix')

      base_message = "#{identifier_label} '#{field.api_identifier}' " \
                     "(#{field_name_prefix}: <strong>#{field.label}</strong>) #{error.message}"

      if conflicting
        conflict_info = "：<strong>#{conflicting.label}</strong> (#{conflicting.field_type_label})"
        "#{base_message}#{conflict_info}".html_safe
      else
        base_message.html_safe
      end
    end

    sig { params(target: T.untyped, error: T.untyped).returns(String) }
    def format_content_type_identifier_error(target, error)
      conflicting = target.conflicting_content_type
      identifier_label = I18n.t('ruler_area.content_models.content_type_identifier_label')

      return "#{identifier_label}#{error.message}" unless conflicting

      type_key = conflicting.is_collection ? 'collection' : 'singleton'
      type_label = I18n.t("ruler_area.content_models.type_labels.#{type_key}")
      conflict_info = "：<strong>#{conflicting.display_name}</strong> (#{type_label})"

      "#{identifier_label} '#{target.unique_name}' #{error.message}#{conflict_info}".html_safe
    end
  end
end
