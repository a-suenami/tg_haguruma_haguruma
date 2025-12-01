# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - serializers - content entries serializer
#
# Serializes a collection of content entries
# ==============================================================================
class ContentEntriesSerializer
  extend T::Sig

  sig { params(resources: T.any(ActiveRecord::Relation, T::Array[ContentEntry])).void }
  def initialize(resources)
    @resources = resources
  end

  sig { params(_options: T::Hash[T.untyped, T.untyped]).returns(T::Hash[Symbol, T.untyped]) }
  def as_json(_options = {})
    {
      data: @resources.map do |resource|
        serializer = ContentEntrySerializer.new(resource)
        serializer.as_json[:data]
      end,
    }
  end

  sig { params(_options: T::Hash[T.untyped, T.untyped]).returns(String) }
  def to_json(_options = {})
    as_json.to_json
  end
end
