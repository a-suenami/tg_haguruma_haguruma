# typed: true

# Shim for TenantSiteSettings JSONB column accessors
# These are database columns but tapioca doesn't generate signatures for them
class TenantSiteSettings
  sig { returns(T.nilable(T::Hash[String, T.untyped])) }
  def features; end

  sig { returns(T.nilable(T::Hash[String, T.untyped])) }
  def landing; end
end
