# typed: strict

module Eventbridge::Handlers
  class BaseHandler
    extend T::Sig
    extend T::Helpers

    abstract!

    sig { abstract.params(detail: T::Hash[T.untyped, T.untyped]).void }
    def handle(detail); end
  end
end
