# typed: strict
# frozen_string_literal: true

module RulerArea
  module Profiles
    # Update Ruler profile (email and password)
    #
    # This service updates Auth0 FIRST, then updates local database.
    # This ensures Auth0 is the source of truth and prevents data inconsistency.
    #
    # Flow:
    # 1. Get Ruler's Auth0Account (from has_many relationship)
    # 2. Call Auth0 Management API to update email (Auth0 validates format)
    # 3. Call Auth0 Management API to update password (if provided)
    # 4. Only if Auth0 succeeds, update local database
    #
    # Usage:
    #   service = RulerArea::Profiles::UpdateService.new(email: '...', password: '...')
    #   result = service.execute(ruler)
    #
    #   if result.success?
    #     # Success
    #   else
    #     errors = result.errors
    #   end
    class UpdateService
      extend T::Sig

      sig { params(email: String, password: T.nilable(String)).void }
      def initialize(email:, password: nil)
        @email = email
        @password = password
      end

      sig { params(ruler: Ruler).returns(Result) }
      def execute(ruler)
        # Get Auth0Account (first from has_many)
        auth0_account = ruler.auth0_accounts.first

        if auth0_account.nil?
          return Result.new(
            success: false,
            errors: ['Auth0 account not found for this Ruler'],
          )
        end

        # Step 1: Update Auth0 FIRST (external API)
        # If Auth0 fails, we don't touch the database
        email_result = Auth0::UpdateEmailService.new(uid: auth0_account.uid, email: @email).execute

        if email_result.failure?
          return Result.new(
            success: false,
            errors: email_result.errors,
          )
        end

        # Update password if provided
        if @password.present?
          password_result = Auth0::UpdatePasswordService.new(uid: auth0_account.uid, password: @password).execute

          if password_result.failure?
            return Result.new(
              success: false,
              errors: password_result.errors,
            )
          end
        end

        # Step 2: Only update database AFTER Auth0 succeeds
        ActiveRecord::Base.transaction do
          auth0_account.email = @email
          auth0_account.save!
        end

        Result.new(success: true, errors: [])
      rescue StandardError => e
        Rails.logger.error("RulerArea::Profiles::UpdateService error: #{e.message}")
        Result.new(success: false, errors: [e.message])
      end

      # Result object for service response
      class Result
        extend T::Sig

        sig { returns(T::Boolean) }
        attr_reader :success

        sig { returns(T::Array[String]) }
        attr_reader :errors

        sig { params(success: T::Boolean, errors: T::Array[String]).void }
        def initialize(success:, errors:)
          @success = success
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
end
