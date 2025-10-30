# typed: strict
# frozen_string_literal: true

class BaseService
  extend T::Sig
  extend T::Helpers

  abstract!

  sig { params(args: T.untyped).void }
  def initialize(**args)
    args.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end
end
