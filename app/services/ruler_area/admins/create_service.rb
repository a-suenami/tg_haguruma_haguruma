# typed: strict
# frozen_string_literal: true

module RulerArea
  module Admins
    # Create Admin with Auth0 account linkage
    #
    # This service:
    # 1. Search for existing Auth0 user by email
    #    - If exists: Reuse Auth0 user (no new Auth0 user created)
    #    - If not exists: Create new Auth0 user
    # 2. Find or create Auth0Account record
    # 3. Check if admin already exists in this tenant with this email
    #    - If exists: Return error
    # 4. Create Admin record
    # 5. Link Admin to Auth0Account via Admin::Auth0Account join table
    #
    # Usage:
    #   service = RulerArea::Admins::CreateService.new(
    #     tenant: tenant,
    #     email: 'admin@example.com',
    #     name: 'Admin Name'
    #   )
    #   result = service.execute
    #
    #   if result.is_a?(Mangrove::Result::Ok)
    #     admin = result.unwrap
    #   else
    #     errors = result.unwrap_err
    #   end
    class CreateService
      extend T::Sig

      sig { params(tenant: Tenant, email: String, name: String).void }
      def initialize(tenant:, email:, name:)
        @tenant = tenant
        @email = email
        @name = name
      end

      sig { returns(Mangrove::Result[Admin, T::Array[String]]) }
      def execute
        # Step 1: Search or create Auth0 user (outside transaction - external API call)
        auth0_user_result = find_or_create_auth0_user
        return Mangrove::Result::Err.new(T.let(auth0_user_result[:errors], T::Array[String])) if auth0_user_result[:errors].present?

        # Step 2: Find or create Auth0Account record (idempotent, can be outside transaction)
        auth0_account = find_or_create_auth0_account(auth0_user_result[:data])

        # Step 3: Check if admin already exists in this tenant (before transaction)
        if admin_exists_in_tenant?(auth0_account)
          return Mangrove::Result::Err.new(T.let([I18n.t('ruler_area.admins.errors.email_already_exists_in_tenant')], T::Array[String]))
        end

        # Step 4 & 5: Database operations only (in transaction)
        admin = T.let(nil, T.nilable(Admin))
        ActiveRecord::Base.transaction do
          # Create Admin record
          admin = Admin.create!(
            tenant: @tenant,
            name: @name,
          )

          # Link Admin to Auth0Account
          Admin::Auth0Account.create!(
            admin:,
            auth0_account:,
            tenant: @tenant,
          )
        end

        Mangrove::Result::Ok.new(T.must(admin))
      rescue ActiveRecord::RecordInvalid => e
        # Return validation errors with i18n from model
        errors = if e.record.respond_to?(:errors)
          e.record.errors.full_messages
        else
          [e.message]
        end
        Mangrove::Result::Err.new(T.let(errors, T::Array[String]))
      end

      private

      sig { params(auth0_account: Auth0Account).returns(T::Boolean) }
      def admin_exists_in_tenant?(auth0_account)
        # Check if this tenant already has an admin linked to this Auth0 account
        Admin::Auth0Account.exists?(
          tenant: @tenant,
          auth0_account:,
        )
      end

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def find_or_create_auth0_user
        # Step 1: Search for existing Auth0 user
        search_result = Auth0::SearchUserService.new(email: @email).execute

        if search_result.is_a?(Mangrove::Result::Ok)
          # User exists, reuse it
          Rails.logger.info("Reusing existing Auth0 user for email: #{@email}")
          { data: search_result.unwrap!, errors: [] }
        else
          # Step 2: User not found, create new one
          Rails.logger.info("Creating new Auth0 user for email: #{@email}")
          create_result = Auth0::CreateUserService.new(email: @email, name: @name).execute

          if create_result.is_a?(Mangrove::Result::Ok)
            { data: create_result.unwrap!, errors: [] }
          else
            # Failed to create user
            { data: nil, errors: create_result.err_inner }
          end
        end
      end

      sig { params(auth0_user: T::Hash[String, T.untyped]).returns(Auth0Account) }
      def find_or_create_auth0_account(auth0_user)
        uid = auth0_user['user_id']
        email = auth0_user['email']

        Auth0Account.find_or_create_by!(email:) do |account|
          account.uid = uid
          account.email = email
        end
      end

    end
  end
end
