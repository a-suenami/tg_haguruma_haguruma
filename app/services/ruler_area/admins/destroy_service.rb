# typed: strict
# frozen_string_literal: true

module RulerArea
  module Admins
    # Delete Admin (hard delete)
    #
    # Note: Does NOT delete Auth0 user
    # Rationale: Auth0 user may be linked to multiple tenants/apps
    #
    # The Admin::Auth0Account join records will be deleted automatically
    # via dependent: :destroy on Admin model
    #
    # Usage:
    #   service = RulerArea::Admins::DestroyService.new(admin: admin)
    #   result = service.execute
    #
    #   if result.success?
    #     # Admin deleted
    #   else
    #     errors = result.errors
    #   end
    class DestroyService
      extend T::Sig

      sig { params(admin: Admin).void }
      def initialize(admin:)
        @admin = admin
      end

      sig { returns(Result) }
      def execute
        @admin.destroy!
        Result.new(success: true, errors: [])
      rescue ActiveRecord::RecordNotDestroyed => e
        Result.new(success: false, errors: [e.message])
      rescue StandardError => e
        Rails.logger.error("RulerArea::Admins::DestroyService error: #{e.message}")
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
