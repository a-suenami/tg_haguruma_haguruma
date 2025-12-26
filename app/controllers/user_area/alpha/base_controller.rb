# typed: true
# frozen_string_literal: true

module UserArea
  module Alpha
    class BaseController < UserArea::ApplicationController
      extend T::Sig

      layout 'user_area/alpha/application'
    end
  end
end
