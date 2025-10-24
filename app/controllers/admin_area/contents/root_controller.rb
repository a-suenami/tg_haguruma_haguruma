# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    class RootController < AdminArea::ApplicationController
      extend T::Sig

      def index
        if mobile_request?
          redirect_to admin_area_contents_mobile_path
        else
          redirect_to admin_area_contents_all_path
        end
      end

      def mobile
        @content_types = ContentType.all
      end
    end
  end
end
