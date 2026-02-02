# Ruler Auth0 Login - Quick Start Guide

## 🎯 Objective
Implement Auth0 login for Ruler Area (Super Admin) in Haguruma application.

---

## 📦 What You Need

### From Auth0 Dashboard
1. Create Application: **Regular Web Application**
2. Get credentials:
   - Domain: `your-tenant.auth0.com`
   - Client ID: `abc123...`
   - Client Secret: `secret123...`
3. Configure URLs:
   - Callback: `http://localhost:3000/ruler/auth/auth0/callback`
   - Logout: `http://localhost:3000/ruler/login`

### Add to `.env.local`
```bash
AUTH0_RULER_DOMAIN=your-tenant.auth0.com
AUTH0_RULER_CLIENT_ID=your_client_id
AUTH0_RULER_CLIENT_SECRET=your_client_secret
```

---

## 🚀 Quick Implementation

### 1. Add Gems (Gemfile)
```ruby
gem 'omniauth', '~> 2.1'
gem 'omniauth-auth0', '~> 3.1'
gem 'omniauth-rails_csrf_protection', '~> 1.0'
```
```bash
source env.sh && bundle install
```

### 2. Database Schema
Create `db/schemas/rulers.schema`:
```ruby
create_table :rulers, id: :uuid, default: -> { 'gen_random_uuid()' } do |t|
  t.string :email, null: false
  t.string :name
  t.string :auth0_account_id, null: false
  t.text :avatar_url
  t.jsonb :metadata, default: {}
  t.timestamps
  t.index :email, unique: true
  t.index :auth0_account_id, unique: true
end
```

Update `db/Schemafile`:
```ruby
require 'schemas/rulers.schema'
```

Apply:
```bash
source env.sh && bundle exec rails ridgepole:apply
```

### 3. Ruler Model
`app/models/ruler.rb`:
```ruby
class Ruler < ApplicationRecord
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :auth0_account_id, presence: true, uniqueness: true

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

### 4. OmniAuth Config
`config/initializers/omniauth.rb`:
```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :auth0,
    Settings.auth0.ruler.client_id,
    Settings.auth0.ruler.client_secret,
    Settings.auth0.ruler.domain,
    callback_path: '/ruler/auth/auth0/callback',
    authorize_params: { scope: 'openid profile email' }
end
OmniAuth.config.allowed_request_methods = [:post, :get]
```

### 5. Routes
Add to `config/routes.rb` inside `ruler_area` namespace:
```ruby
get '/auth/auth0/callback', to: 'sessions#create'
get '/auth/failure', to: 'sessions#failure'
get '/login', to: 'sessions#new', as: :login
delete '/logout', to: 'sessions#destroy', as: :logout
```

### 6. Sessions Controller
`app/controllers/ruler_area/sessions_controller.rb`:
```ruby
module RulerArea
  class SessionsController < ApplicationController
    skip_before_action :authenticate!, only: [:new, :create, :failure]

    def new; end

    def create
      ruler = Ruler.from_omniauth(request.env['omniauth.auth'])
      session[:ruler_id] = ruler.id
      redirect_to ruler_area_root_path, notice: 'ログインしました'
    rescue => e
      Sentry.capture_exception(e)
      redirect_to ruler_area_login_path, alert: 'ログインに失敗しました'
    end

    def destroy
      session.delete(:ruler_id)
      redirect_to ruler_area_login_path, notice: 'ログアウトしました'
    end

    def failure
      redirect_to ruler_area_login_path, alert: "認証に失敗しました"
    end
  end
end
```

### 7. Update Application Controller
`app/controllers/ruler_area/application_controller.rb`:
```ruby
before_action :authenticate!
helper_method :current_ruler, :signed_in?

private

def authenticate!
  redirect_to ruler_area_login_path unless signed_in?
end

def current_ruler
  @current_ruler ||= Ruler.find_by(id: session[:ruler_id]) if session[:ruler_id]
end

def signed_in?
  current_ruler.present?
end
```

### 8. Login View
`app/views/ruler_area/sessions/new.html.erb`:
```erb
<div class="uk-flex uk-flex-center uk-flex-middle" style="min-height: 80vh;">
  <div class="uk-card uk-card-default uk-card-body uk-width-large">
    <div class="uk-text-center uk-margin-medium-bottom">
      <%= image_tag 'ruler_area/haguruma-logo.svg', width: '200' %>
      <h2 class="uk-card-title">Ruler Area</h2>
    </div>
    <%= button_to 'Auth0でログイン', '/ruler/auth/auth0',
        method: :post,
        class: 'uk-button uk-button-primary uk-button-large uk-width-1-1',
        data: { turbo: false } %>
  </div>
</div>
```

### 9. Update Layout Navbar
In `app/views/layouts/ruler_area/application.html.erb`, update navbar right:
```erb
<div class="uk-navbar-right">
  <ul class="uk-navbar-nav">
    <% if signed_in? %>
      <li>
        <a href="#">
          <%= current_ruler.name || current_ruler.email %>
        </a>
        <div class="uk-navbar-dropdown">
          <ul class="uk-nav uk-navbar-dropdown-nav">
            <li><%= current_ruler.email %></li>
            <li class="uk-nav-divider"></li>
            <li>
              <%= button_to 'ログアウト', ruler_area_logout_path,
                  method: :delete,
                  class: 'uk-button uk-button-text',
                  data: { turbo: false } %>
            </li>
          </ul>
        </div>
      </li>
    <% end %>
  </ul>
</div>
```

### 10. Restart & Test
```bash
docker-compose restart app
```

Visit: http://localhost:3000/ruler/login

---

## 🧪 Quick Test

```bash
# Run tests
source env.sh && bundle exec rspec spec/models/ruler_spec.rb

# Type check
srb tc .

# Lint
bundle exec rubocop -A
```

---

## 📚 Full Documentation

See [RULER_AUTH0_LOGIN_SPEC.md](./RULER_AUTH0_LOGIN_SPEC.md) for complete details.

---

## ⏱️ Estimated Time: 5-6 hours
