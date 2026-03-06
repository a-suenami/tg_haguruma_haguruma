# typed: strict
# frozen_string_literal: true

require 'json-schema'

class LexicalJsonValidator < ActiveModel::EachValidator
  extend T::Sig

  # Lexical JSON Schema definition
  # https://lexical.dev/docs/concepts/serialization
  LEXICAL_NODE_SCHEMA = T.let({
    type: 'object',
    required: %w[type version],
    properties: {
      type: { type: 'string' },
      version: { type: 'integer', minimum: 1 },
      children: {
        type: 'array',
        items: { '$ref': '#/definitions/node' },
      },
    },
    additionalProperties: true,
  }.freeze, T::Hash[Symbol, T.untyped],)

  SCHEMA = T.let({
    type: 'object',
    required: ['root'],
    properties: {
      root: {
        type: 'object',
        required: %w[type version children],
        properties: {
          type: { enum: ['root'] },
          version: { type: 'integer', minimum: 1 },
          children: {
            type: 'array',
            items: { '$ref': '#/definitions/node' },
          },
          direction: {
            type: %w[string null],
          },
          format: { type: 'string' },
          indent: { type: 'integer' },
        },
        additionalProperties: true,
      },
    },
    additionalProperties: false,
    definitions: {
      node: LEXICAL_NODE_SCHEMA,
    },
  }.freeze, T::Hash[Symbol, T.untyped],)

  # Allowed node types (Lexical built-in + custom nodes)
  ALLOWED_NODE_TYPES = T.let(%w[
    root
    paragraph
    text
    heading
    quote
    list
    listitem
    link
    autolink
    linebreak
    tab
    code
    code-highlight
    horizontal-rule
    table
    tablecell
    tablerow
    mark
    overflow
    image
    video
    auto-embed
  ].freeze, T::Array[String],)

  # ProseMirror indicators (for rejection)
  PROSEMIRROR_INDICATORS = T.let(%w[doc content marks].freeze, T::Array[String])

  sig { params(record: T.untyped, attribute: Symbol, value: T.untyped).void }
  def validate_each(record, attribute, value)
    return if value.blank?

    # Ensure value is a Hash (jsonb column may pass a JSON string)
    parsed_value = if value.is_a?(String)
      begin
        JSON.parse(value)
      rescue JSON::ParserError
        record.errors.add(attribute, :invalid_json, message: options[:message] || 'is not valid JSON')
        return
      end
    else
      value
    end

    return unless parsed_value.is_a?(Hash)

    # Check for ProseMirror format
    if prosemirror_format?(parsed_value)
      record.errors.add(attribute, :prosemirror_format, message: options[:prosemirror_message] || 'ProseMirror format is not accepted. Please use Lexical format.')
      return
    end

    # Validate against JSON Schema
    schema_errors = JSON::Validator.fully_validate(SCHEMA.deep_stringify_keys, parsed_value)
    if schema_errors.any?
      record.errors.add(attribute, :invalid_lexical_structure, message: options[:message] || "is not a valid Lexical JSON structure: #{schema_errors.first}")
      return
    end

    # Validate node types
    unknown_types = collect_unknown_node_types(parsed_value)
    if unknown_types.any?
      record.errors.add(attribute, :unknown_node_types, message: options[:node_type_message] || "contains unknown node types: #{unknown_types.join(', ')}")
    end
  end

  private

  sig { params(value: T::Hash[String, T.untyped]).returns(T::Boolean) }
  def prosemirror_format?(value)
    # ProseMirror uses 'doc' as root type and 'content' for children
    return true if value['doc'].present?
    return true if value['type'] == 'doc'

    if (root = value['root']) && root['content'].is_a?(Array)
      return true
    end

    false
  end

  sig { params(value: T::Hash[String, T.untyped]).returns(T::Array[String]) }
  def collect_unknown_node_types(value)
    unknown_types = T.let(Set.new, T::Set[String])
    collect_node_types_recursive(value['root'], unknown_types)
    unknown_types.to_a
  end

  sig { params(node: T.untyped, unknown_types: T::Set[String]).void }
  def collect_node_types_recursive(node, unknown_types)
    return unless node.is_a?(Hash)

    node_type = node['type']
    if node_type.present? && ALLOWED_NODE_TYPES.exclude?(node_type)
      unknown_types.add(node_type)
    end

    children = node['children']
    return unless children.is_a?(Array)

    children.each do |child|
      collect_node_types_recursive(child, unknown_types)
    end
  end
end
