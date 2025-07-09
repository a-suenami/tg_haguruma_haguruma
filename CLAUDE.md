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