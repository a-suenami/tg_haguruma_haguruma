# typed: true
# frozen_string_literal: true

module UserArea
  module Alpha
    class PrivilegesController < BaseController
      extend T::Sig

      include ContentLoadable
      source_content_type :faq

      sig { void }
      def show
        entries = query_entries(page: 1, limit: 100)
        @faq_entries = entries.sort_by do |entry|
          version = entry.versions.find(&:published?)
          next Float::INFINITY if version.nil?

          position_field = version.fields.find { |f| f.content_type_field&.api_identifier == 'position' }
          position_field&.text&.value.to_i || Float::INFINITY
        end
      end
    end
  end
end
