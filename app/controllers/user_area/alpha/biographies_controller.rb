# typed: true
# frozen_string_literal: true

module UserArea
  module Alpha
    class BiographiesController < BaseController
      extend T::Sig

      include ContentLoadable
      source_content_type :biography

      sig { void }
      def index
        @entries = query_entries(page: params[:page]&.to_i || 1)
      end

      sig { void }
      def show
        @entries = [find_singleton_entry]
      end
    end
  end
end
