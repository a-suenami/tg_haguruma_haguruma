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
