# typed: false
# frozen_string_literal: true

namespace :lexical do
  desc 'Validate all existing richtext data against Lexical JSON schema'
  task validate: :environment do
    puts 'Validating richtext data...'
    puts

    total_count = ContentEntry::FieldRichtext.count
    invalid_records = []
    prosemirror_records = []

    ContentEntry::FieldRichtext.find_each.with_index do |record, index|
      print "\rChecking record #{index + 1}/#{total_count}..." if (index % 100).zero?

      # Create a temporary object for validation
      test_record = ContentEntry::FieldRichtext.new(value: record.value)
      validator = LexicalJsonValidator.new(attributes: [:value])
      validator.validate_each(test_record, :value, record.value)

      next if test_record.errors.empty?

      error_info = {
        id: record.id,
        errors: test_record.errors.full_messages,
        sample: record.value.to_json.truncate(300),
      }

      if test_record.errors[:value].any? { |e| e.include?('ProseMirror') }
        prosemirror_records << error_info
      else
        invalid_records << error_info
      end
    end

    puts "\r#{' ' * 50}\r" # Clear progress line
    puts '=' * 60
    puts 'Validation Results'
    puts '=' * 60
    puts

    if prosemirror_records.empty? && invalid_records.empty?
      puts "✓ All #{total_count} records are valid Lexical JSON"
    else
      if prosemirror_records.any?
        puts "⚠ ProseMirror format detected: #{prosemirror_records.size} records"
        puts '-' * 40
        prosemirror_records.first(10).each do |r|
          puts "  ID: #{r[:id]}"
          puts "  Sample: #{r[:sample]}"
          puts
        end
        puts "  ... and #{prosemirror_records.size - 10} more" if prosemirror_records.size > 10
        puts
      end

      if invalid_records.any?
        puts "✗ Invalid Lexical JSON: #{invalid_records.size} records"
        puts '-' * 40
        invalid_records.first(10).each do |r|
          puts "  ID: #{r[:id]}"
          puts "  Errors: #{r[:errors].join(', ')}"
          puts "  Sample: #{r[:sample]}"
          puts
        end
        puts "  ... and #{invalid_records.size - 10} more" if invalid_records.size > 10
      end

      puts
      puts '=' * 60
      puts 'Summary'
      puts '=' * 60
      puts "Total records:      #{total_count}"
      puts "Valid:              #{total_count - prosemirror_records.size - invalid_records.size}"
      puts "ProseMirror format: #{prosemirror_records.size}"
      puts "Invalid structure:  #{invalid_records.size}"
    end
  end

  desc 'Show sample of richtext data for inspection'
  task sample: :environment do
    puts 'Sample richtext data (first 5 records):'
    puts

    ContentEntry::FieldRichtext.limit(5).each do |record|
      puts "ID: #{record.id}"
      puts 'Value:'
      puts JSON.pretty_generate(record.value).lines.map { |l| "  #{l}" }.join
      puts '-' * 40
      puts
    end
  end
end
