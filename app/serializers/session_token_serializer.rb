# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - serializers - session token serializer
# ==============================================================================
class SessionTokenSerializer < ApplicationSerializer
  attributes :created_at, :expires_at
end
