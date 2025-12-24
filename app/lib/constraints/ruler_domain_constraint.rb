# typed: false
# frozen_string_literal: true

module Constraints
  class RulerDomainConstraint
    def matches?(request)
      request.host_with_port == Settings.domains.ruler
    end
  end
end
