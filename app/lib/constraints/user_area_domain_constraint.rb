# typed: false
# frozen_string_literal: true

module Constraints
  class UserAreaDomainConstraint
    def matches?(request)
      Tenant.exists?(user_page_domain: request.host)
    end
  end
end
