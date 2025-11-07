# typed: strict
# frozen_string_literal: true

# auth service for id-platform.net
module Auth
  module Tokens
    class IssueService < BaseService
      extend T::Sig

      sig { params(user: User, expires_in: Integer).returns(SessionToken) }
      def execute(user:, expires_in: 90.days.to_i)
        # minimum required entropy is 128bit. alphanumeric(22) satisfies this requirement but we use 24 to be safe.
        # 24 char alphanumeric has 143bit entropy.
        session_token = SessionToken.create!(
          id: SecureRandom.alphanumeric(24),
          user_id: user.id,
          tenant_id: user.tenant_id,
          expires_at: (Time.current + expires_in).to_datetime,
        )
        session_token
      end
    end
  end
end
