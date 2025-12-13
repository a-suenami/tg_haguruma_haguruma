# typed: strict
# frozen_string_literal: true

module Ruler
  # Ensure Ruler is registered as Admin for a tenant
  #
  # This service ensures that a Ruler has an Admin record for accessing
  # a specific tenant's admin area. If an Admin already exists for the
  # Ruler's Auth0 account in that tenant, no action is taken.
  #
  # Usage:
  #   service = Ruler::EnsureAdminService.new(
  #     ruler: current_ruler,
  #     tenant: tenant
  #   )
  #   result = service.execute
  #
  #   if result.is_a?(Mangrove::Result::Ok)
  #     admin = result.unwrap  # existing or newly created Admin
  #   else
  #     errors = result.unwrap_err
  #   end
  class EnsureAdminService
    extend T::Sig

    sig { params(ruler: ::Ruler, tenant: Tenant).void }
    def initialize(ruler:, tenant:)
      @ruler = ruler
      @tenant = tenant
    end

    sig { returns(Mangrove::Result[Admin, T::Array[String]]) }
    def execute
      auth0_account = @ruler.auth0_account
      return Mangrove::Result::Err.new(['Auth0 account not found for ruler']) if auth0_account.nil?

      # Check if Admin already exists for this auth0_account in this tenant
      existing_link = Admin::Auth0Account.find_by(auth0_account_id: auth0_account.id, tenant_id: @tenant.id)
      return Mangrove::Result::Ok.new(existing_link.admin) if existing_link.present?

      # Create Admin and link to Auth0Account
      admin = T.let(nil, T.nilable(Admin))
      ActiveRecord::Base.transaction do
        admin = Admin.create!(
          tenant_id: @tenant.id,
          name: @ruler.name || auth0_account.email,
        )
        Admin::Auth0Account.create!(
          admin:,
          auth0_account:,
          tenant_id: @tenant.id,
        )
      end

      Mangrove::Result::Ok.new(T.must(admin))
    rescue ActiveRecord::RecordInvalid => e
      errors = if e.record.respond_to?(:errors)
        e.record.errors.full_messages
      else
        [e.message]
      end
      Mangrove::Result::Err.new(T.let(errors, T::Array[String]))
    end
  end
end
