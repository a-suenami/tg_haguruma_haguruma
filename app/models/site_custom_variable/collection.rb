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
  end
end
