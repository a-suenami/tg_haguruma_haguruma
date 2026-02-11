# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - controllers - api - v1 - auth - idp controller
# ==============================================================================
# implement Twogate's IdP (id-platform.net) auth flows
module Api
  module V1
    module Auth
      class IdpController < Api::V1::Auth::ApplicationController
        extend T::Sig

        # returns the information necessary for the OAuth client to construct the Authorization URL.
        sig { void }
        def provider
          render json: ::OauthProviderSerializer.new(@user_oauth_provider)
          set_cache_control_headers(max_age: 1.minute)
        end

        sig { void }
        def session
          id_token = ::Auth::IdPlatform::VerifyIdTokenService.new(
            oauth_provider: T.must(@user_oauth_provider),
          ).execute(id_token_jwt: params['id_token'].to_s)

          user = ::Users::FindOrCreateByUidService.new(
            provider: T.must(@user_oauth_provider),
            uid: id_token['sub'],
          ).execute

          # Sync IDP tags from ID token
          idp_tags = id_token.dig('user', 'tags') || []
          ::Users::SyncIdpTagsService.new(user:, tags: idp_tags).execute if idp_tags.present?

          token = ::Auth::Tokens::IssueService.new.execute(
            user:,
            expires_in: T.must(@user_oauth_provider).session_expires_in,
          )

          render json: ::SessionTokenSerializer.new(token)
        end

        private

        sig { params(max_age: ActiveSupport::Duration).void }
        def set_cache_control_headers(max_age:)
          response.headers['Cache-Control'] = "public, max-age=#{max_age.to_i}"
        end
      end
    end
  end
end
