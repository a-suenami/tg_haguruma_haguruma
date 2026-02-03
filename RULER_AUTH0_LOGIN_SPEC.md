# Ruler Area - Auth0 Login Implementation Specification

## 📋 Overview

Implement Auth0 authentication for the Ruler Area (Super Admin) of Haguruma application. Rulers can manage multiple tenants and need secure authentication.

**Target URL**: `http://localhost:3000/ruler` (Development)

---

## 🎯 Requirements

### Functional Requirements
1. Ruler can login using Auth0 (Social login or Username/Password)
2. After successful login, redirect to Tenants list page
3. Display logged-in Ruler's information in navbar (avatar, name, email)
4. Ruler can logout from the system
5. Protect all Ruler Area routes with authentication
6. Session-based authentication using Rails session

### Non-Functional Requirements
1. Secure authentication flow following OAuth 2.0 / OIDC standards
2. Handle authentication failures gracefully
3. Support both development and production environments
4. Type-safe implementation using Sorbet
5. Full test coverage (model, controller specs)

---

## 🏗️ System Architecture

### Current Architecture
- **Framework**: Ruby on Rails 8.0.2
- **Frontend**: TypeScript + UIKit CSS + Turbo Rails (Hotwire)
- **Database**: PostgreSQL 16
- **Type Checking**: Sorbet
- **Testing**: RSpec
- **Database Migration**: Ridgepole (NOT Rails migrations)

### Authentication Flow
```
┌─────────┐         ┌──────────────┐         ┌─────────┐
│ Browser │────────▶│ Ruler Area   │────────▶│ Auth0   │
│         │  Login  │ (Rails App)  │ Redirect│         │
└─────────┘         └──────────────┘         └─────────┘
     ▲                      │                      │
     │                      │                      │
     │                      │   Auth Callback     │
     │                      │◀─────────────────────┘
     │                      │
     │   Create Session    │
     │◀─────────────────────┘
     │
     │   Redirect to Tenants
     │
```

---

## 📂 File Structure

### New Files to Create
```
app/
├── models/
│   └── ruler.rb                                    # New Ruler model
├── controllers/
│   └── ruler_area/
│       └── sessions_controller.rb                  # New Sessions controller
├── views/
│   └── ruler_area/
│       └── sessions/
│           └── new.html.erb                        # Login page
config/
└── initializers/
    └── omniauth.rb                                 # OmniAuth configuration
db/
└── schemas/
    └── rulers.schema                               # Ridgepole schema
spec/
├── factories/
│   └── rulers.rb                                   # Factory for testing
├── models/
│   └── ruler_spec.rb                               # Model tests
└── requests/
    └── ruler_area/
        └── sessions_spec.rb                        # Controller tests
```

### Files to Modify
```
Gemfile                                             # Add omniauth gems
config/routes.rb                                    # Add auth routes
config/settings.yml                                 # Already has Auth0 config
db/Schemafile                                       # Add rulers schema
app/controllers/ruler_area/application_controller.rb  # Enable authentication
app/views/layouts/ruler_area/application.html.erb  # Add user info/logout
.env.local                                          # Add Auth0 credentials
```

---

## 💾 Database Schema

### Rulers Table
```ruby
# db/schemas/rulers.schema

create_table :rulers, id: :uuid, default: -> { 'gen_random_uuid()' } do |t|
  t.string :email, null: false, comment: 'Ruler email address'
  t.string :name, comment: 'Ruler full name'
  t.string :auth0_account_id, null: false, comment: 'Auth0 user ID (e.g., auth0|123456)'
  t.text :avatar_url, comment: 'Profile picture URL'
  t.jsonb :metadata, default: {}, comment: 'Additional user metadata'

  t.timestamps

  t.index :email, unique: true
  t.index :auth0_account_id, unique: true
end
```

**Apply Schema Command**:
```bash
source env.sh && bundle exec rails ridgepole:apply
```

---

## 🔧 Implementation Details

### 1. Dependencies (Gemfile)

Add these gems to `Gemfile`:

```ruby
# Authentication
gem 'omniauth', '~> 2.1'
gem 'omniauth-auth0', '~> 3.1'
gem 'omniauth-rails_csrf_protection', '~> 1.0'
```

**Installation Command**:
```bash
source env.sh && bundle install
```

---

### 2. Ruler Model

**File**: `app/models/ruler.rb`

```ruby
# typed: strict
# frozen_string_literal: true

class Ruler < ApplicationRecord
  extend T::Sig

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :auth0_account_id, presence: true, uniqueness: true

  # Create or update Ruler from Auth0 callback
  sig { params(auth_hash: T::Hash[String, T.untyped]).returns(Ruler) }
  def self.from_omniauth(auth_hash)
    ruler = find_or_initialize_by(auth0_account_id: auth_hash['uid'])

    ruler.assign_attributes(
      email: auth_hash.dig('info', 'email'),
      name: auth_hash.dig('info', 'name'),
      avatar_url: auth_hash.dig('info', 'image')
    )

    ruler.save!
    ruler
  end
end
```

**Key Points**:
- UUID as primary key for security
- `from_omniauth` method handles create/update from Auth0 callback
- Stores Auth0 user ID for linking

---

### 3. OmniAuth Configuration

**File**: `config/initializers/omniauth.rb`

```ruby
# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :auth0,
    Settings.auth0.ruler.client_id,
    Settings.auth0.ruler.client_secret,
    Settings.auth0.ruler.domain,
    callback_path: '/ruler/auth/auth0/callback',
    authorize_params: {
      scope: 'openid profile email'
    }
end

# Security: Allow POST for CSRF protection
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true
```

---

### 4. Routes Configuration

**File**: `config/routes.rb`

Add these routes inside the `ruler_area` namespace:

```ruby
namespace :ruler_area, path: :ruler do
  # Authentication routes (ADD THESE)
  get '/auth/auth0/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  get '/login', to: 'sessions#new', as: :login
  delete '/logout', to: 'sessions#destroy', as: :logout

  # Existing routes
  root to: 'tenants#index', as: :root

  resources :tenants do
    # ... existing routes
  end
end
```

**Route Helpers Available**:
- `ruler_area_login_path` → `/ruler/login`
- `ruler_area_logout_path` → `/ruler/logout`
- `/ruler/auth/auth0` → Auth0 login redirect (POST only)
- `/ruler/auth/auth0/callback` → Auth0 callback

---

### 5. Sessions Controller

**File**: `app/controllers/ruler_area/sessions_controller.rb`

```ruby
# typed: true
# frozen_string_literal: true

module RulerArea
  class SessionsController < ApplicationController
    skip_before_action :authenticate!, only: [:new, :create, :failure]

    # GET /ruler/login
    def new
      # Render login page
      redirect_to ruler_area_root_path if signed_in?
    end

    # GET /ruler/auth/auth0/callback
    def create
      auth_hash = request.env['omniauth.auth']
      ruler = Ruler.from_omniauth(auth_hash)

      session[:ruler_id] = ruler.id

      redirect_to ruler_area_root_path, notice: 'ログインしました'
    rescue StandardError => e
      Sentry.capture_exception(e)
      redirect_to ruler_area_login_path, alert: 'ログインに失敗しました'
    end

    # DELETE /ruler/logout
    def destroy
      session.delete(:ruler_id)
      reset_session
      redirect_to ruler_area_login_path, notice: 'ログアウトしました'
    end

    # GET /ruler/auth/failure
    def failure
      redirect_to ruler_area_login_path, alert: "認証に失敗しました: #{params[:message]}"
    end
  end
end
```

---

### 6. Application Controller Update

**File**: `app/controllers/ruler_area/application_controller.rb`

```ruby
# typed: true
# frozen_string_literal: true

module RulerArea
  class ApplicationController < ActionController::Base
    layout 'ruler_area/application'

    # Enable authentication
    before_action :authenticate!
    helper_method :current_ruler, :signed_in?

    private

    def authenticate!
      redirect_to ruler_area_login_path unless signed_in?
    end

    def current_ruler
      return nil if session[:ruler_id].blank?
      @current_ruler ||= Ruler.find_by(id: session[:ruler_id])
    end

    def signed_in?
      current_ruler.present?
    end

    def set_tenant
      @tenant = Tenant.find(params[:tenant_id])
      RequestStore.store[:current_tenant] = @tenant.id
      Tenant.current
    end
  end
end
```

**Note**: Remove all commented TODO code related to authentication.

---

### 7. Login View

**File**: `app/views/ruler_area/sessions/new.html.erb`

```erb
<div class="uk-flex uk-flex-center uk-flex-middle" style="min-height: 80vh;">
  <div class="uk-card uk-card-default uk-card-body uk-width-large">
    <div class="uk-text-center uk-margin-medium-bottom">
      <%= image_tag 'ruler_area/haguruma-logo.svg', alt: 'Haguruma', width: '200', class: 'uk-margin-bottom' %>
      <h2 class="uk-card-title uk-margin-small-top">Ruler Area</h2>
      <p class="uk-text-muted">管理者としてログインしてください</p>
    </div>

    <div class="uk-text-center">
      <%= button_to 'Auth0でログイン',
          '/ruler/auth/auth0',
          method: :post,
          class: 'uk-button uk-button-primary uk-button-large uk-width-1-1',
          data: { turbo: false } %>
    </div>

    <% if flash[:alert] %>
      <div class="uk-alert-danger uk-margin-top" uk-alert>
        <a class="uk-alert-close" uk-close></a>
        <p><%= flash[:alert] %></p>
      </div>
    <% end %>
  </div>
</div>
```

**Important**: `data: { turbo: false }` is required to bypass Turbo for OAuth flow.

---

### 8. Layout Update - User Info & Logout

**File**: `app/views/layouts/ruler_area/application.html.erb`

Update the navbar right section (around line 40):

```erb
<div class="uk-navbar-right">
  <ul class="uk-navbar-nav">
    <% if signed_in? %>
      <li>
        <a href="#">
          <% if current_ruler.avatar_url.present? %>
            <%= image_tag current_ruler.avatar_url,
                alt: current_ruler.name,
                class: 'uk-border-circle',
                style: 'width: 32px; height: 32px; margin-right: 8px;' %>
          <% else %>
            <span uk-icon="icon: user; ratio: 1.2" class="uk-margin-small-right"></span>
          <% end %>
          <%= current_ruler.name || current_ruler.email %>
        </a>
        <div class="uk-navbar-dropdown">
          <ul class="uk-nav uk-navbar-dropdown-nav">
            <li class="uk-nav-header">
              <%= current_ruler.email %>
            </li>
            <li class="uk-nav-divider"></li>
            <li>
              <%= link_to '#' do %>
                <span uk-icon="icon: settings" class="uk-margin-small-right"></span>
                アカウント設定
              <% end %>
            </li>
            <li class="uk-nav-divider"></li>
            <li>
              <%= button_to ruler_area_logout_path,
                  method: :delete,
                  class: 'uk-button uk-button-text uk-text-danger',
                  style: 'width: 100%; text-align: left;',
                  data: { turbo: false } do %>
                <span uk-icon="icon: sign-out" class="uk-margin-small-right"></span>
                ログアウト
              <% end %>
            </li>
          </ul>
        </div>
      </li>
    <% end %>
  </ul>
</div>
```

---

## 🔐 Auth0 Configuration

### Step 1: Create Application on Auth0

1. Login to [Auth0 Dashboard](https://manage.auth0.com/)
2. Navigate to **Applications** → **Create Application**
3. Choose:
   - **Name**: `Haguruma Ruler Area`
   - **Application Type**: `Regular Web Application`
   - **Technology**: `Ruby on Rails`

### Step 2: Configure Application Settings

**Allowed Callback URLs**:
```
http://localhost:3000/ruler/auth/auth0/callback
https://ruler.yourdomain.com/ruler/auth/auth0/callback
```

**Allowed Logout URLs**:
```
http://localhost:3000/ruler/login
https://ruler.yourdomain.com/ruler/login
```

**Allowed Web Origins**:
```
http://localhost:3000
https://ruler.yourdomain.com
```

**Allowed Origins (CORS)**:
```
http://localhost:3000
https://ruler.yourdomain.com
```

### Step 3: Get Credentials

From the **Settings** tab, copy:
- **Domain** (e.g., `your-tenant.auth0.com` or `your-tenant.jp.auth0.com`)
- **Client ID** (e.g., `abc123xyz...`)
- **Client Secret** (e.g., `secret123...`)

### Step 4: Update Environment Variables

**File**: `.env.local`

Add these lines:

```bash
# Auth0 Ruler Area Configuration
AUTH0_RULER_DOMAIN=your-tenant.auth0.com
AUTH0_RULER_CLIENT_ID=your_client_id_here
AUTH0_RULER_CLIENT_SECRET=your_client_secret_here
```

**Note**: These variables are already configured in `config/settings.yml:18-21`

---

## 🧪 Testing

### Factory Definition

**File**: `spec/factories/rulers.rb`

```ruby
# typed: false

FactoryBot.define do
  factory :ruler do
    email { FFaker::Internet.email }
    name { FFaker::Name.name }
    auth0_account_id { "auth0|#{SecureRandom.hex(12)}" }
    avatar_url { FFaker::Avatar.image }
  end
end
```

### Model Spec

**File**: `spec/models/ruler_spec.rb`

```ruby
# typed: false

describe Ruler do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:auth0_account_id) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_uniqueness_of(:auth0_account_id) }
  end

  describe '.from_omniauth' do
    let(:auth_hash) do
      {
        'uid' => 'auth0|12345',
        'info' => {
          'email' => 'test@example.com',
          'name' => 'Test User',
          'image' => 'https://example.com/avatar.jpg'
        }
      }
    end

    context 'when ruler does not exist' do
      it 'creates a new ruler' do
        expect { Ruler.from_omniauth(auth_hash) }.to change(Ruler, :count).by(1)
      end

      it 'sets correct attributes' do
        ruler = Ruler.from_omniauth(auth_hash)

        expect(ruler.email).to eq('test@example.com')
        expect(ruler.name).to eq('Test User')
        expect(ruler.auth0_account_id).to eq('auth0|12345')
        expect(ruler.avatar_url).to eq('https://example.com/avatar.jpg')
      end
    end

    context 'when ruler already exists' do
      let!(:existing_ruler) do
        create(:ruler,
          auth0_account_id: 'auth0|12345',
          email: 'old@example.com',
          name: 'Old Name'
        )
      end

      it 'does not create a new ruler' do
        expect { Ruler.from_omniauth(auth_hash) }.not_to change(Ruler, :count)
      end

      it 'updates existing ruler' do
        ruler = Ruler.from_omniauth(auth_hash)

        expect(ruler.id).to eq(existing_ruler.id)
        expect(ruler.email).to eq('test@example.com')
        expect(ruler.name).to eq('Test User')
      end
    end
  end
end
```

### Controller Spec

**File**: `spec/requests/ruler_area/sessions_spec.rb`

```ruby
# typed: false

describe 'RulerArea::Sessions', type: :request do
  describe 'GET /ruler/login' do
    context 'when not signed in' do
      it 'renders login page' do
        get ruler_area_login_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'when already signed in' do
      let(:ruler) { create(:ruler) }

      before do
        allow_any_instance_of(RulerArea::SessionsController)
          .to receive(:current_ruler).and_return(ruler)
        allow_any_instance_of(RulerArea::SessionsController)
          .to receive(:signed_in?).and_return(true)
      end

      it 'redirects to root' do
        get ruler_area_login_path
        expect(response).to redirect_to(ruler_area_root_path)
      end
    end
  end

  describe 'GET /ruler/auth/auth0/callback' do
    let(:auth_hash) do
      {
        'uid' => 'auth0|12345',
        'info' => {
          'email' => 'test@example.com',
          'name' => 'Test User',
          'image' => 'https://example.com/avatar.jpg'
        }
      }
    end

    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:auth0] = OmniAuth::AuthHash.new(auth_hash)
    end

    it 'creates session and redirects' do
      get '/ruler/auth/auth0/callback'

      expect(session[:ruler_id]).to be_present
      expect(response).to redirect_to(ruler_area_root_path)
    end

    it 'creates or updates ruler' do
      expect { get '/ruler/auth/auth0/callback' }.to change(Ruler, :count).by(1)
    end
  end

  describe 'DELETE /ruler/logout' do
    let(:ruler) { create(:ruler) }

    before do
      post '/ruler/auth/auth0/callback'
    end

    it 'clears session and redirects' do
      delete ruler_area_logout_path

      expect(session[:ruler_id]).to be_nil
      expect(response).to redirect_to(ruler_area_login_path)
    end
  end
end
```

**Run Tests**:
```bash
source env.sh && bundle exec rspec spec/models/ruler_spec.rb
source env.sh && bundle exec rspec spec/requests/ruler_area/sessions_spec.rb
```

---

## 🚀 Implementation Steps

### Step-by-Step Execution

```bash
# 1. Add gems to Gemfile (manually edit)
# Then install:
source env.sh && bundle install

# 2. Create Ruler model
touch app/models/ruler.rb

# 3. Create Sessions controller
mkdir -p app/controllers/ruler_area
touch app/controllers/ruler_area/sessions_controller.rb

# 4. Create login view
mkdir -p app/views/ruler_area/sessions
touch app/views/ruler_area/sessions/new.html.erb

# 5. Create OmniAuth initializer
touch config/initializers/omniauth.rb

# 6. Create database schema
touch db/schemas/rulers.schema

# 7. Update Schemafile
# Add: require 'schemas/rulers.schema'

# 8. Apply database schema
source env.sh && bundle exec rails ridgepole:apply

# 9. Update routes.rb (manually)

# 10. Update application_controller.rb (manually)

# 11. Update layout file (manually)

# 12. Update .env.local with Auth0 credentials

# 13. Restart application
docker-compose restart app

# 14. Test login flow
# Open: http://localhost:3000/ruler/login
```

---

## ✅ Acceptance Criteria

### Must Have
- [ ] Ruler can access login page at `/ruler/login`
- [ ] Clicking "Login" redirects to Auth0 login page
- [ ] After successful Auth0 authentication, redirect to `/ruler` (Tenants list)
- [ ] Session is created and stored in Rails session
- [ ] Ruler's name/email/avatar is displayed in navbar
- [ ] Ruler can logout via navbar dropdown
- [ ] All Ruler Area routes require authentication
- [ ] Unauthenticated access redirects to login page
- [ ] Error messages are displayed for failed authentication

### Should Have
- [ ] RSpec tests pass (model, controller)
- [ ] Sorbet type checking passes: `srb tc .`
- [ ] RuboCop linting passes: `rubocop -A`
- [ ] Login page UI matches Ruler Area design (UIKit)

### Nice to Have
- [ ] Remember last visited page and redirect after login
- [ ] Session timeout after inactivity
- [ ] Activity logging for Ruler actions

---

## 🐛 Common Issues & Solutions

### Issue 1: OmniAuth CSRF Protection Error
**Error**: `OmniAuth::AuthenticityError`

**Solution**:
- Ensure `omniauth-rails_csrf_protection` gem is installed
- Use POST method for auth redirect: `button_to '/ruler/auth/auth0', method: :post`
- Add `data: { turbo: false }` to bypass Turbo

### Issue 2: Callback URL Mismatch
**Error**: `redirect_uri_mismatch` from Auth0

**Solution**:
- Verify callback URL in Auth0 dashboard matches exactly
- Check for trailing slashes
- Ensure protocol (http/https) matches

### Issue 3: Session Not Persisting
**Error**: User logged out immediately after login

**Solution**:
- Check `config/session_store.rb` configuration
- Verify cookies are enabled in browser
- Check `SameSite` cookie policy in production

### Issue 4: Infinite Redirect Loop
**Error**: Keeps redirecting between login and root

**Solution**:
- Verify `skip_before_action :authenticate!` in SessionsController
- Check `signed_in?` method logic
- Ensure session is properly set in `create` action

---

## 📚 References

### Documentation Links
- [OmniAuth Auth0 Strategy](https://github.com/auth0/omniauth-auth0)
- [Auth0 Rails Quickstart](https://auth0.com/docs/quickstart/webapp/rails)
- [Rails Session Management](https://guides.rubyonrails.org/action_controller_overview.html#session)
- [Ridgepole Documentation](https://github.com/ridgepole/ridgepole)
- [Sorbet Type System](https://sorbet.org/docs/overview)

### Existing Code References
- Auth0 config: `config/settings.yml:18-21`
- Ruler routes: `config/routes.rb:16-28`
- Current controller: `app/controllers/ruler_area/application_controller.rb`
- Layout template: `app/views/layouts/ruler_area/application.html.erb`
- Frontend: `app/frontend/entrypoints/ruler_area/application.ts`

---

## 📝 Notes for Developer

1. **Database Migration**: This project uses **Ridgepole**, NOT Rails migrations. Always use `bundle exec rails ridgepole:apply` to apply schema changes.

2. **Type Checking**: Run `srb tc .` after making changes to ensure type safety.

3. **Testing**: Follow the project's testing patterns. Use `source env.sh && bundle exec rspec` for running tests.

4. **Code Style**: Run `bundle exec rubocop -A` to auto-fix style issues.

5. **Docker Environment**: Most commands should be prefixed with `source env.sh &&` to run inside Docker containers.

6. **Auth0 Testing**: Use Auth0's test users or create your own test account for development.

7. **Session Security**: In production, ensure secure session configuration with `secure: true` and proper `SameSite` policy.

---

## 🎯 Success Metrics

- [ ] Developer can complete implementation in 4-6 hours
- [ ] All tests pass on first run
- [ ] Zero security vulnerabilities from authentication flow
- [ ] Login flow works in both development and production environments
- [ ] Documentation is clear and complete

---

**Document Version**: 1.0
**Last Updated**: 2025-10-17
**Author**: Claude Code
**Project**: Haguruma - Ruler Area Authentication
