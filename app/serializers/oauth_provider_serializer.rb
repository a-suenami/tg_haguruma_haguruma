# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - serializers - oauth provider serializer
# ==============================================================================
class OauthProviderSerializer < ApplicationSerializer
  # DO NOT EXPOSE client_secret !ヤバイ！！
  attributes :client_id, :endpoint_base, :scopes
end
