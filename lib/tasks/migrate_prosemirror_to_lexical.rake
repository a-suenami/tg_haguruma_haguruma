# typed: false
# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :richtext do
  desc 'Fix nested html format to proper Lexical format'
  task fix_nested_html: :environment do
    puts 'Fixing nested html format richtext...'

    fixed_count = 0
    skipped_count = 0

    ContentEntry::FieldRichtext.find_each do |richtext|
      value = richtext.value

      # Check if it has html key with string value
      next unless value.is_a?(Hash) && value['html'].is_a?(String)

      begin
        # Try to parse the html value
        parsed = JSON.parse(value['html'])

        # If it's still nested, unwrap again
        parsed = JSON.parse(parsed['html']) while parsed.is_a?(Hash) && parsed['html'].is_a?(String)

        # Check if we got valid Lexical format
        if parsed.is_a?(Hash) && parsed['root'].present?
          richtext.update!(value: parsed)
          fixed_count += 1
          puts "Fixed ID #{richtext.id}"
        else
          skipped_count += 1
          puts "Skipping ID #{richtext.id}: Not valid Lexical format after unwrapping"
        end
      rescue JSON::ParserError => e
        skipped_count += 1
        puts "Skipping ID #{richtext.id}: #{e.message}"
      end
    end

    puts "\nFix complete!"
    puts "Fixed: #{fixed_count}"
    puts "Skipped: #{skipped_count}"
  end

  desc 'Migrate ProseMirror format richtext to Lexical format'
  task migrate_to_lexical: :environment do
    puts 'Starting migration from ProseMirror to Lexical format...'

    migrated_count = 0
    skipped_count = 0
    error_count = 0

    ContentEntry::FieldRichtext.find_each do |richtext|
      value = richtext.value

      # Skip if already Lexical format
      if value.is_a?(Hash) && value['root'].present?
        skipped_count += 1
        next
      end

      # Skip if not ProseMirror format
      unless value.is_a?(Hash) && value['type'] == 'doc' && value['content'].is_a?(Array)
        puts "Skipping ID #{richtext.id}: Unknown format"
        skipped_count += 1
        next
      end

      begin
        # Convert ProseMirror to Lexical
        lexical_content = convert_prosemirror_to_lexical(value)
        richtext.update!(value: lexical_content)
        migrated_count += 1
        puts "Migrated ID #{richtext.id}"
      rescue StandardError => e
        error_count += 1
        puts "Error migrating ID #{richtext.id}: #{e.message}"
      end
    end

    puts "\nMigration complete!"
    puts "Migrated: #{migrated_count}"
    puts "Skipped: #{skipped_count}"
    puts "Errors: #{error_count}"
  end

  def convert_prosemirror_to_lexical(prosemirror)
    {
      'root' => {
        'type' => 'root',
        'format' => '',
        'indent' => 0,
        'version' => 1,
        'children' => convert_prosemirror_content(prosemirror['content']),
        'direction' => 'ltr',
      },
    }
  end

  def convert_prosemirror_content(content)
    return [] unless content.is_a?(Array)

    content.map { |node| convert_prosemirror_node(node) }.compact
  end

  def convert_prosemirror_node(node)
    case node['type']
    when 'paragraph'
      {
        'type' => 'paragraph',
        'format' => '',
        'indent' => 0,
        'version' => 1,
        'children' => convert_prosemirror_inline_content(node['content']),
        'direction' => 'ltr',
        'textFormat' => 0,
      }
    when 'heading'
      level = node.dig('attrs', 'level') || 1
      {
        'tag' => "h#{level}",
        'type' => 'heading',
        'format' => '',
        'indent' => 0,
        'version' => 1,
        'children' => convert_prosemirror_inline_content(node['content']),
        'direction' => 'ltr',
      }
    when 'bulletList', 'bullet_list'
      {
        'tag' => 'ul',
        'type' => 'list',
        'start' => 1,
        'format' => '',
        'indent' => 0,
        'version' => 1,
        'children' => convert_prosemirror_list_items(node['content']),
        'listType' => 'bullet',
        'direction' => 'ltr',
      }
    when 'orderedList', 'ordered_list'
      {
        'tag' => 'ol',
        'type' => 'list',
        'start' => 1,
        'format' => '',
        'indent' => 0,
        'version' => 1,
        'children' => convert_prosemirror_list_items(node['content']),
        'listType' => 'number',
        'direction' => 'ltr',
      }
    when 'blockquote'
      {
        'type' => 'quote',
        'format' => '',
        'indent' => 0,
        'version' => 1,
        'children' => convert_prosemirror_content(node['content']),
        'direction' => 'ltr',
      }
    when 'codeBlock', 'code_block'
      # Code block - extract text content
      text = extract_text_from_prosemirror(node)
      {
        'type' => 'code',
        'format' => '',
        'indent' => 0,
        'version' => 1,
        'children' => [
          {
            'mode' => 'normal',
            'text' => text,
            'type' => 'code-highlight',
            'style' => '',
            'version' => 1,
          },
        ],
        'language' => node.dig('attrs', 'language') || '',
        'direction' => 'ltr',
      }
    else
      # Unknown block type - convert to paragraph
      {
        'type' => 'paragraph',
        'format' => '',
        'indent' => 0,
        'version' => 1,
        'children' => convert_prosemirror_inline_content(node['content']),
        'direction' => 'ltr',
        'textFormat' => 0,
      }
    end
  end

  def convert_prosemirror_list_items(items)
    return [] unless items.is_a?(Array)

    items.map do |item|
      next unless item['type'] == 'listItem' || item['type'] == 'list_item'

      {
        'type' => 'listitem',
        'value' => 1,
        'format' => '',
        'indent' => 0,
        'version' => 1,
        'children' => convert_prosemirror_content(item['content']),
        'direction' => 'ltr',
      }
    end.compact
  end

  def convert_prosemirror_inline_content(content)
    return [] unless content.is_a?(Array)

    content.map { |node| convert_prosemirror_inline_node(node) }.compact
  end

  def convert_prosemirror_inline_node(node)
    case node['type']
    when 'text'
      format = calculate_text_format(node['marks'])
      {
        'mode' => 'normal',
        'text' => node['text'] || '',
        'type' => 'text',
        'style' => '',
        'format' => format,
        'detail' => 0,
        'version' => 1,
      }
    when 'hardBreak', 'hard_break'
      {
        'type' => 'linebreak',
        'version' => 1,
      }
    else
      # Unknown inline type - try to extract text
      if node['text']
        {
          'mode' => 'normal',
          'text' => node['text'],
          'type' => 'text',
          'style' => '',
          'format' => 0,
          'detail' => 0,
          'version' => 1,
        }
      end
    end
  end

  def calculate_text_format(marks)
    return 0 unless marks.is_a?(Array)

    format = 0
    marks.each do |mark|
      case mark['type']
      when 'bold', 'strong'
        format |= 1  # Bold
      when 'italic', 'em'
        format |= 2  # Italic
      when 'underline'
        format |= 8  # Underline
      when 'strike', 'strikethrough'
        format |= 4  # Strikethrough
      when 'code'
        format |= 16 # Code
      end
    end
    format
  end

  def extract_text_from_prosemirror(node)
    return node['text'] if node['text']
    return '' unless node['content'].is_a?(Array)

    node['content'].map { |child| extract_text_from_prosemirror(child) }.join
  end
end
# rubocop:enable Metrics/BlockLength
