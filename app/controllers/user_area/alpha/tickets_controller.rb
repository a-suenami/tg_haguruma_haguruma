# typed: true
# frozen_string_literal: true

module UserArea
  module Alpha
    class TicketsController < BaseController
      extend T::Sig

      sig { void }
      def index
        # Ticket list page
      end

      sig { void }
      def show
        # Ticket detail page
      end
    end
  end
end
