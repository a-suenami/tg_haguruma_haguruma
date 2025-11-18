# typed: strict

# Manual type signatures for Auth0Client
# The gem's RBI doesn't properly inherit methods from Auth0::Api::V2::Users
class Auth0Client
  # Search users by query
  # @param q [String] Lucene query string
  # @return [Array<Hash>] Array of user hashes
  sig { params(q: String).returns(T::Array[T::Hash[String, T.untyped]]) }
  def users(q:); end

  # Create a new user in a specific connection
  # @param connection [String] Connection name (e.g. 'Username-Password-Authentication')
  # @param user_data [Hash] User data (email, password, name, etc.)
  # @return [Hash] Created user hash
  sig { params(connection: String, user_data: T::Hash[T.untyped, T.untyped]).returns(T::Hash[String, T.untyped]) }
  def create_user(connection, user_data); end

  # Update a user by ID
  # @param user_id [String] Auth0 user ID
  # @param attributes [Hash] User attributes to update (email, password, name, etc.)
  # @return [Hash] Updated user hash
  sig { params(user_id: String, attributes: T::Hash[T.untyped, T.untyped]).returns(T::Hash[String, T.untyped]) }
  def patch_user(user_id, attributes); end

  # Delete a user by ID
  # @param user_id [String] Auth0 user ID
  # @return [void]
  sig { params(user_id: String).void }
  def delete_user(user_id); end
end
