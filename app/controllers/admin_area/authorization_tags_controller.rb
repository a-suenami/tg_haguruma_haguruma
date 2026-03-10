# typed: true
# frozen_string_literal: true

module AdminArea
  class AuthorizationTagsController < AdminArea::ApplicationController
    extend T::Sig

    sig { void }
    def index
      @authorization_tags = ContentAuthorizationTag.searchable.order(:name)
    end
  end
end
