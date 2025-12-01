# typed: true
# frozen_string_literal: true

# ==============================================================================
# app - queries - application query
#
# Base class for query objects with fluent interface support
# ==============================================================================
class ApplicationQuery
  extend T::Sig
  extend T::Helpers
  extend T::Generic

  abstract!

  EntityType = type_member { { upper: ActiveRecord::Base } }

  class << self
    extend T::Sig

    # Enable class method chaining by delegating to a new instance
    # rubocop:disable Style/ArgumentsForwarding, Naming/BlockForwarding
    sig { params(method_name: Symbol, args: T.untyped, block: T.nilable(T.proc.void)).returns(T.untyped) }
    def method_missing(method_name, *args, &block)
      instance = new
      if instance.respond_to?(method_name)
        T.unsafe(instance).public_send(method_name, *args, &block)
      else
        super
      end
    end
    # rubocop:enable Style/ArgumentsForwarding, Naming/BlockForwarding

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

  # Returns typed array of entities
  sig { returns(T::Array[EntityType]) }
  def resolve
    T.unsafe(call.to_a)
  end

  # Returns first entity with proper type
  sig { returns(T.nilable(EntityType)) }
  def resolve_first
    T.unsafe(call.first)
  end

  # Finds entity by id with proper type
  sig { params(id: T.untyped).returns(EntityType) }
  def resolve_find(id)
    T.unsafe(call.find(id))
  end

  # Finds entity by id, returns nil if not found
  sig { params(id: T.untyped).returns(T.nilable(EntityType)) }
  def resolve_find_by_id(id)
    T.unsafe(call.find_by(id:))
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
