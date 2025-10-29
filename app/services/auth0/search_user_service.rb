# typed: strict
# frozen_string_literal: true

module Auth0
  # Search for Auth0 Database user by email (Username-Password-Authentication only)
  #
  # Note: This only searches for users in Auth0 Database connection.
  # It will NOT find users from Google OAuth, Facebook, or other social connections.
  #
  # Usage:
  #   service = Auth0::SearchUserService.new(email: 'user@example.com')
  #   result = service.execute
  #
  #   if result.success?
  #     user = result.user # Auth0 Database user data
  #   else
  #     errors = result.errors
  #   end
  class SearchUserService < BaseService
    extend T::Sig

    sig { params(email: String).void }
    def initialize(email:)
      @email = email
    end

    sig { returns(Result) }
    def execute
      # Only search for Database connection users (not Google OAuth, Facebook, etc.)
      query = "email:\"#{@email}\" AND identities.connection:\"Username-Password-Authentication\""
      users = client.users(q: query)

      if users.empty?
        Result.new(success: false, user: nil, errors: ['User not found'])
      else
        Result.new(success: true, user: users.first, errors: [])
      end
    rescue StandardError => e
      Rails.logger.error("Auth0::SearchUserService error: #{e.message}")
      Result.new(success: false, user: nil, errors: [e.message])
    end

    # Result object for service response
    class Result
      extend T::Sig

      sig { returns(T::Boolean) }
      attr_reader :success

      sig { returns(T.nilable(T::Hash[String, T.untyped])) }
      attr_reader :user

      sig { returns(T::Array[String]) }
      attr_reader :errors

      sig { params(success: T::Boolean, user: T.nilable(T::Hash[String, T.untyped]), errors: T::Array[String]).void }
      def initialize(success:, user:, errors:)
        @success = success
        @user = user
        @errors = errors
      end

      sig { returns(T::Boolean) }
      def success?
        @success
      end

      sig { returns(T::Boolean) }
      def failure?
        !@success
      end
    end
  end
end
