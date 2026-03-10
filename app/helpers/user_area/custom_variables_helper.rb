# frozen_string_literal: true

module UserArea
  module CustomVariablesHelper
    def custom_variables
      @custom_variables ||= SiteCustomVariable::Collection.new(SiteCustomVariable.active.to_a)
    end
  end
end
