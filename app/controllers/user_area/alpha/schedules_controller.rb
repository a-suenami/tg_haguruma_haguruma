# typed: true
# frozen_string_literal: true

module UserArea
  module Alpha
    class SchedulesController < BaseController
      extend T::Sig

      sig { void }
      def index
        # Schedule list page
      end

      sig { void }
      def show
        # Schedule detail page
      end
    end
  end
end
