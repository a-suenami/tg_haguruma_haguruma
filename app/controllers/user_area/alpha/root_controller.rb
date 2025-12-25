# typed: true
# frozen_string_literal: true

module UserArea
  module Alpha
    class RootController < BaseController
      extend T::Sig

      sig { void }
      def index
        # Alpha root page
      end
    end
  end
end
