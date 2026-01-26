# typed: strict
# frozen_string_literal: true

class SiteCustomVariable
  class Collection
    extend T::Sig
    extend T::Generic
    include Enumerable

    Elem = type_member { { fixed: SiteCustomVariable } }

    sig { params(variables: T::Array[SiteCustomVariable]).void }
    def initialize(variables)
      @variables = variables
      @hash = T.let(variables.index_by(&:unique_name), T::Hash[String, SiteCustomVariable])
    end

    sig { params(key: String).returns(T.nilable(SiteCustomVariable)) }
    def [](key)
      @hash[key]
    end

    sig { override.params(block: T.proc.params(var: SiteCustomVariable).void).returns(T.untyped) }
    def each(&block)
      @variables.each(&block)
    end

    # Boolean helpers
    sig { params(key: String).returns(T::Boolean) }
    def enabled?(key)
      var = @hash[key]
      return false unless var&.variable_type_boolean?

      var.boolean_value == true
    end

    # Datetime helpers
    sig { params(key: String).returns(T::Boolean) }
    def past?(key)
      var = @hash[key]
      return false unless var&.variable_type_datetime?

      T.must(var.datetime_value) <= Time.current
    end

    sig { params(key: String).returns(T::Boolean) }
    def future?(key)
      var = @hash[key]
      return false unless var&.variable_type_datetime?

      T.must(var.datetime_value) > Time.current
    end

    alias passed? past?
    alias not_passed? future?

    # Text helper
    sig { params(key: String).returns(String) }
    def text(key)
      var = @hash[key]
      return '' unless var&.variable_type_text?

      var.text_value || ''
    end
  end
end
