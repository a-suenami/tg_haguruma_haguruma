# typed: strict
# frozen_string_literal: true

module AdminArea
  module Profiles
    # Update Admin profile (email and password)
    #
    # This service updates Auth0 FIRST, then updates local database.
    # This ensures Auth0 is the source of truth and prevents data inconsistency.
    #
    # Flow:
    # 1. Get Admin's Auth0Account (from has_many relationship)
    # 2. Call Auth0 Management API to update email and/or password (separate API calls)
    #    - Only call email API if email has changed (optimization)
    #    - Only call password API if password is provided
    # 3. Only if Auth0 succeeds, update local database
    #
    # Usage:
    #   service = AdminArea::Profiles::UpdateService.new(email: '...', password: '...')
    #   result = service.execute(admin)
    #
    #   if result.is_a?(Mangrove::Result::Ok)
    #     # Success
    #   else
    #     errors = result.err_inner
    #   end
    class UpdateService
      extend T::Sig

      sig { params(email: String, password: T.nilable(String)).void }
      def initialize(email:, password: nil)
        @email = email
        @password = password
      end

      sig { params(admin: Admin).returns(Mangrove::Result[T::Boolean, T::Array[String]]) }
      def execute(admin)
        # Get Auth0Account (first from has_many)
        auth0_account = admin.auth0_accounts.first

        if auth0_account.nil?
          return Mangrove::Result::Err.new(T.let(['Auth0 account not found for this Admin'], T::Array[String]))
        end

        # Step 1: Update Auth0 FIRST (external API)

        # Update email only if it has changed
        if auth0_account.email != @email
          email_result = Auth0::UpdateEmailService.new(
            uid: auth0_account.uid,
            email: @email,
          ).execute

          if email_result.is_a?(Mangrove::Result::Err)
            return Mangrove::Result::Err.new(email_result.err_inner)
          end
        end

        # Update password only if provided
        if @password.present?
          password_result = Auth0::UpdatePasswordService.new(
            uid: auth0_account.uid,
            password: @password,
          ).execute

          if password_result.is_a?(Mangrove::Result::Err)
            return Mangrove::Result::Err.new(password_result.err_inner)
          end
        end

        # Step 2: Only update database AFTER Auth0 succeeds
        # Only update email in DB if it changed
        if auth0_account.email != @email
          ActiveRecord::Base.transaction do
            auth0_account.email = @email
            auth0_account.save!
          end
        end

        Mangrove::Result::Ok.new(T.let(true, T::Boolean))
      rescue StandardError => e
        Rails.logger.error("AdminArea::Profiles::UpdateService error: #{e.message}")
        Mangrove::Result::Err.new(T.let([e.message], T::Array[String]))
      end
    end
  end
end
