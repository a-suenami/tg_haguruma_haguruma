# typed: true
# frozen_string_literal: true

module UserArea
  module Alpha
    class PrivilegesController < BaseController
      extend T::Sig

      sig { void }
      def show
        # Static page - no data needed
      end
    end
  end
end
