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
        @faq_entries = query_entries(page: 1, limit: 100)
      end
    end
  end
end
