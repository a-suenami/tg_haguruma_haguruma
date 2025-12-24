# typed: false
# frozen_string_literal: true

module Constraints
  class AdminDomainConstraint
    def matches?(request)
      # Settings.domains.admin may include port (e.g., "admin.example.com:3000")
      # Expected pattern: {tenant-id}.{admin_host}
      admin_host = Settings.domains.admin&.split(':')&.first
      return false if admin_host.blank?

      # Check if host ends with admin_host and has a tenant-id prefix
      request.host.end_with?(".#{admin_host}")
    end
  end
end
