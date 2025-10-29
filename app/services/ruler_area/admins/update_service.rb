# typed: strict
# frozen_string_literal: true

module RulerArea
  module Admins
    # Update Admin attributes
    #
    # Note: Does not update Auth0 user or email (email is stored in Auth0Account, not Admin)
    # Admin table only has: id, tenant_id, name, created_at, updated_at
    # Email comes from linked Auth0Account
    #
    # Usage:
    #   service = RulerArea::Admins::UpdateService.new(
    #     admin: admin,
    #     name: 'New Name'
    #   )
    #   result = service.execute
    #
    #   if result.success?
    #     admin = result.admin
    #   else
    #     errors = result.errors
    #   end
    class UpdateService
      extend T::Sig

      sig { params(admin: Admin, name: String).void }
      def initialize(admin:, name:)
        @admin = admin
        @name = name
      end

      sig { returns(Result) }
      def execute
        @admin.update!(
          name: @name,
        )

        Result.new(success: true, admin: @admin, errors: [])
      rescue ActiveRecord::RecordInvalid => e
        # Return the invalid record so controller can access validation errors
        Result.new(success: false, admin: @admin, errors: [e.message])
      rescue StandardError => e
        Rails.logger.error("RulerArea::Admins::UpdateService error: #{e.message}")
        Result.new(success: false, admin: @admin, errors: [e.message])
      end

      # Result object for service response
      class Result
        extend T::Sig

        sig { returns(T::Boolean) }
        attr_reader :success

        sig { returns(T.nilable(Admin)) }
        attr_reader :admin

        sig { returns(T::Array[String]) }
        attr_reader :errors

        sig { params(success: T::Boolean, admin: T.nilable(Admin), errors: T::Array[String]).void }
        def initialize(success:, admin:, errors:)
          @success = success
          @admin = admin
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
