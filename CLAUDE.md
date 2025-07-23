# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rails 8.0.2 API application (HagurumaApi) using modern Rails defaults including Hotwire, Import Maps, and the Solid suite (Cache, Queue, Cable).

## Essential Commands

### Development Setup
```bash
bin/setup          # Initial setup - installs dependencies and prepares database
```

### Development Server
```bash
bin/dev            # Start Rails development server
bin/rails server   # Alternative server start command
```

### Database Operations
```bash
bin/rails db:create    # Create database
bin/rails db:migrate   # Run pending migrations  
bin/rails db:prepare   # Complete database setup (create + migrate + seed)
bin/rails db:seed      # Load seed data
```

### Testing
```bash
bin/rails test                 # Run all tests
bin/rails test test/models/    # Run specific test directory
bin/rails test test/models/user_test.rb  # Run specific test file
bin/rails test:system          # Run system tests
```

### Code Quality
```bash
bin/rubocop        # Run linting (Rails Omakase style)
bin/rubocop -a     # Auto-fix linting issues
bin/brakeman       # Security analysis
```

### Console & Debugging
```bash
bin/rails console  # Interactive Rails console
bin/rails c        # Shorthand for console
```

### Deployment
```bash
bin/kamal          # Deploy using Kamal
```

## Architecture Overview

### Core Stack
- **Ruby**: 3.4.4
- **Rails**: 8.0.2
- **Database**: SQLite3 (with separate databases for cache, queue, and cable in production)
- **Frontend**: Hotwire (Turbo + Stimulus) with Import Maps
- **Background Jobs**: Solid Queue
- **WebSockets**: Solid Cable (Action Cable)
- **Asset Pipeline**: Propshaft

### Directory Structure
- Standard Rails MVC structure
- `config/` - Application configuration including database, routes, and deployment
- `app/` - Application code (models, views, controllers, jobs, mailers, channels)
- `test/` - Minitest test suite
- `db/` - Database migrations and schema
- `public/` - Static files
- `storage/` - SQLite databases and Active Storage files

### Key Configuration Files
- `config/database.yml` - Database configuration
- `config/routes.rb` - Application routes
- `config/deploy.yml` - Kamal deployment configuration
- `.rubocop.yml` - Linting rules (inherits from rubocop-rails-omakase)
- `Dockerfile` - Production container configuration

### Testing Approach
- Uses Minitest (Rails default)
- Tests located in `test/` directory
- System tests configured with Capybara and Selenium
- Parallel testing enabled for performance

### Production Deployment
- Containerized with Docker
- Deployed via Kamal
- Uses Thruster for HTTP acceleration
- Multiple SQLite databases for different concerns (main, cache, queue, cable)
- Asset precompilation during Docker build

## Running commands in Docker
For projects using Docker, you should run `source env.sh` before running any command intended to be run inside the container.

example: `source env.sh && bundle exec rails ridgepole:apply`

## Rails Project
- We're using ridgepole for database migrations. Use `source env.sh && bundle exec rails ridgepole:apply` instead of `rails db:migrate`.
- Use Sorbet for type checking in some rails projects.
    - Always run `srb tc .` when you modified the Ruby code
    - Run `source env.sh && tapioca gem` when you installed new gems
    - Run `source env.sh && tapioca dsl` when you modified the database schema, routes, or models
- Use RuboCop for code style checking in some rails projects.
    - Always run `rubocop -A` when you modified the Ruby code

## Test Writing in This Project

### 1. No rails_helper
- This project doesn't use `rails_helper` in tests
- Use direct `describe` blocks without requiring rails_helper
- Example:
  ```ruby
  # typed: false
  
  describe SevenElevenRecord::Client do
    # test code here
  end
  ```

### 2. Tenant Setup Required
- Many models require a current tenant to be set
- Tenant factory requires explicit ID (validation: "IDを選択してください")
- Standard pattern:
  ```ruby
  let(:tenant) { create(:tenant, id: 'sample') }
  
  before do
    Tenant.current_id = tenant.id
  end
  ```

### 3. RuboCop Style Requirements
- Always add trailing newline at end of file
- Use `described_class` instead of explicit class names
- Add trailing commas in multiline hashes/arrays
- Fix unused block arguments with underscore prefix (`_field`)
- Run `rubocop -A` after writing tests

### 4. Test Execution (for simple tests)
- Always use `source env.sh` before running tests in Docker environment
- Example: `source env.sh && bundle exec rspec spec/models/...`
- DON'T RUN rspec without a file path (`source env.sh && bundle exec rspec`) as it may be extremely slow due to the large number of specs. Use `rspec_parallel` instead.

### 5. Parallel Tests (for entire tests)
- Use `rspec_parallel` alias to run tests in parallel (much faster)
- Example: `source env.sh && rspec_parallel`

## Edit CLAUDE.md for memory
If there are any hard-won know-how or discoveries (regarding tacit knowledge) that you struggled with, organize and write them out at the end of CLAUDE.md.