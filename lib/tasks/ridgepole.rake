# typed: false

# ==============================================================================
# lib - tasks - ridgepole
# ==============================================================================
namespace :ridgepole do
  desc 'Apply database schema'
  task apply: :environment do
    check_non_required_schemas if Rails.env.development?

    ridgepole('--apply', "--file #{schema_file}", '--allow-pk-change')

    if Rails.env.development?
      print "\n"
      puts 'Re-creating test database...'
      suppress_output do
        # test の DB を利用する
        Rails.env = 'test'

        Rake::Task['db:drop'].invoke
        Rake::Task['db:create'].invoke

        ridgepole('--apply', "--file #{schema_file}", '--env test')

        # schema.rb と structure.sql の両方吐かせる
        ENV['SCHEMA_FORMAT'] = 'ruby'
        Rake::Task['db:schema:dump'].invoke
        ENV['SCHEMA_FORMAT'] = 'sql'
        Rake::Task['db:schema:dump'].invoke

        system('FORCE_TEST_DATABASE=true bin/tapioca dsl', exception: true)
        system('RAILS_ENV=test bundle exec annotaterb models', exception: true)
      end
      puts 'done'
    end
  end

  task dry: :environment do
    ridgepole('--apply', '--dry-run --verbose', "--file #{schema_file}", '--allow-pk-change')
  end

  desc 'Export database schema'
  task export: :environment do
    ridgepole('--export --split', "--output #{schema_file}")
  end

  private

  def schema_file
    Rails.root.join('db/Schemafile')
  end

  def config_file
    if ENV['DATABASE_URL'].present?
      uri = URI.parse(ENV.fetch('DATABASE_URL', nil))

      if [uri.scheme, uri.user, uri.password, uri.host, uri.path].any?(&:nil?)
        raise 'Invalid DATABASE_URL: missing required components (scheme, user, password, host, or path)'
      end

      # for fuckin' heroku uri scheme
      uri.scheme = 'postgresql' if uri.scheme == 'postgres'

      # Write config to temp file to avoid exposing credentials in command line
      @temp_config_file ||= begin
        require 'tempfile'
        file = Tempfile.new(['ridgepole_config', '.yml'])
        file.write({
          'adapter' => uri.scheme,
          'username' => uri.user,
          'password' => uri.password,
          'host' => uri.host,
          'database' => uri.path.sub(%r{\A/}, ''),
        }.to_yaml)
        file.close
        file.path
      end

    else
      Rails.root.join('config/database.yml')
    end
  end

  def check_non_required_schemas
    schema_file_content = File.read(schema_file)
    requirements = schema_file_content.scan(%r{require 'schemas/.*$}).map { _1.match(/(schemas.*)'/)[1] }
    schema_files = Dir.glob(Rails.root.join('db/schemas/**/*.schema')).map { _1.match(/(schemas.*)/)[1] } # rubocop:disable Rails/RootPathnameMethods

    diff = schema_files - requirements

    puts("\033[33mWarning:\033[m There are unapplied schemas:")
    puts(diff.join("\n"))
  end

  def ridgepole(*options)
    config = config_file
    command = ['bundle exec ridgepole', "--config #{config}"]
    full_command = [command + options].join(' ')

    success = system(full_command)
    return if success

    # Raise error without exposing the config file path (which might reveal it's a temp file with credentials)
    sanitized_options = options.reject { |opt| opt.include?('--config') }
    raise "Ridgepole command failed: bundle exec ridgepole #{sanitized_options.join(' ')} (exit status: #{$CHILD_STATUS&.exitstatus})"
  ensure
    # Clean up temp file if it was created
    if @temp_config_file && File.exist?(@temp_config_file)
      File.unlink(@temp_config_file)
      @temp_config_file = nil
    end
  end

  def suppress_output
    original_stdout = $stdout.clone
    original_stderr = $stderr.clone
    $stdout.reopen File.new('/dev/null', 'w')
    $stderr.reopen File.new('/dev/null', 'w')
    yield
  ensure
    $stdout.reopen original_stdout
    $stderr.reopen original_stderr
  end
end
