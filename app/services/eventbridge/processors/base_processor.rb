# typed: strict

module Eventbridge::Processors
  class BaseProcessor
    extend T::Sig

    sig { overridable.params(message: T.untyped).void }
    def process(message); end
  end
end
