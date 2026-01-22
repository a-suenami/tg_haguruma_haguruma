# typed: true
# frozen_string_literal: true

module UserArea
  module Alpha
    class TicketsController < BaseController
      extend T::Sig

      include ContentLoadable
      source_content_type :ticket

      sig { void }
      def index
        @entries = query_entries(
          select_options: { category: current_category },
          page: params[:page]&.to_i || 1,
        )
      end

      sig { void }
      def show
        @entry = find_entry(params[:id])
      end
    end
  end
end
