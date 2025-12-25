# typed: true
# frozen_string_literal: true

module UserArea
  module Alpha
    class BaseController < UserArea::ApplicationController
      extend T::Sig

      layout 'user_area/alpha/application'

      # TODO: Remove this when authentication is ready for alpha pages
      skip_before_action :authenticate!
    end
  end
end
