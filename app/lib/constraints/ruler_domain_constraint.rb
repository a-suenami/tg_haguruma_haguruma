# typed: false
# frozen_string_literal: true

module Constraints
  class RulerDomainConstraint
    def matches?(request)
      # Settings.domains.ruler may include port (e.g., "ruler.example.com:3000")
      # Compare only the host part
      ruler_host = Settings.domains.ruler&.split(':')&.first
      request.host == ruler_host
    end
  end
end
