# typed: false
# frozen_string_literal: true

module Constraints
  class AdminDomainConstraint
    def matches?(request)
      request.host.include?('.admin.')
    end
  end
end
