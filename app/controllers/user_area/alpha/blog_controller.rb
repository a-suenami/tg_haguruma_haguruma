# typed: true
# frozen_string_literal: true

module UserArea
  module Alpha
    class BlogController < BaseController
      extend T::Sig

      sig { void }
      def index
        # Blog list page
      end

      sig { void }
      def show
        # Blog detail page
      end
    end
  end
end
