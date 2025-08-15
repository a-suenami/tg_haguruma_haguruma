# typed: true
# frozen_string_literal: true

class AdminArea::ApplicationController < ApplicationController
  extend T::Sig

  layout 'admin_area/application'
end
