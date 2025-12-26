# typed: true
# frozen_string_literal: true

module UserArea
  module Alpha
    class NewsController < BaseController
      extend T::Sig

      sig { void }
      def index
        # News list page
      end

      sig { void }
      def show
        # News detail page
      end
    end
  end
end
