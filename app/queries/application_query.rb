# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - queries - application query
#
# Base class for query objects with fluent interface support
# ==============================================================================
class ApplicationQuery
  extend T::Sig
  extend T::Helpers

  abstract!

  class << self
    extend T::Sig

    # Enable class method chaining by delegating to a new instance
    sig { params(method_name: Symbol, args: T.untyped, block: T.nilable(T.proc.void)).returns(T.untyped) }
    def method_missing(method_name, *, &)
      instance = new
      if instance.respond_to?(method_name)
        instance.public_send(method_name, *, &)
      else
        super
      end
    end

    sig { params(method_name: Symbol, include_private: T::Boolean).returns(T::Boolean) }
    def respond_to_missing?(method_name, include_private = false)
      new.respond_to?(method_name) || super
    end
  end

  sig { void }
  def initialize
    @scope = T.let(base_scope, ActiveRecord::Relation)
  end

  # Returns the final ActiveRecord::Relation
  sig { returns(ActiveRecord::Relation) }
  def call
    @scope
  end

  # Delegate common ActiveRecord methods
  sig { returns(T::Array[T.untyped]) }
  delegate :to_a, to: :call

  sig { returns(T.untyped) }
  delegate :first, to: :call

  sig { params(id: T.untyped).returns(T.untyped) }
  delegate :find, to: :call

  sig { params(id: T.untyped).returns(T.untyped) }
  def find_by_id(id)
    call.find_by(id: id)
  end

  sig { params(block: T.proc.params(record: T.untyped).void).void }
  def each(&)
    call.each(&)
  end

  private

  # Subclasses must define the base scope
  sig { abstract.returns(ActiveRecord::Relation) }
  def base_scope; end

  # Helper to update scope and return self for chaining
  sig { params(new_scope: ActiveRecord::Relation).returns(T.self_type) }
  def chain(new_scope)
    @scope = new_scope
    self
  end
end
