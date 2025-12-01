# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - queries - application query
# ==============================================================================
class ApplicationQuery
  extend T::Sig
  extend T::Helpers

  abstract!

  sig { void }
  def initialize
    # Base initializer
  end

  sig { abstract.returns(ActiveRecord::Relation) }
  def call; end
end
