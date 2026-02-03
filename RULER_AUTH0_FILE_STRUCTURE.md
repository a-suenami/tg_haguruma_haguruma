# Ruler Auth0 Login - File Structure Reference

## 📁 Complete File Tree

```
haguruma/
├── .env.local                                      [MODIFY] Add Auth0 credentials
├── Gemfile                                         [MODIFY] Add omniauth gems
│
├── config/
│   ├── routes.rb                                   [MODIFY] Add auth routes
│   ├── settings.yml                                [EXISTS] Auth0 config already present
│   └── initializers/
│       └── omniauth.rb                             [CREATE] OmniAuth configuration
│
├── db/
│   ├── Schemafile                                  [MODIFY] Require rulers.schema
│   └── schemas/
│       └── rulers.schema                           [CREATE] Rulers table definition
│
├── app/
│   ├── models/
│   │   └── ruler.rb                                [CREATE] Ruler model
│   │
│   ├── controllers/
│   │   └── ruler_area/
│   │       ├── application_controller.rb           [MODIFY] Enable authentication
│   │       └── sessions_controller.rb              [CREATE] Handle login/logout
│   │
│   └── views/
│       ├── ruler_area/
│       │   └── sessions/
│       │       └── new.html.erb                    [CREATE] Login page
│       └── layouts/
│           └── ruler_area/
│               └── application.html.erb            [MODIFY] Add user info/logout
│
└── spec/
    ├── factories/
    │   └── rulers.rb                               [CREATE] Test factory
    ├── models/
    │   └── ruler_spec.rb                           [CREATE] Model tests
    └── requests/
        └── ruler_area/
            └── sessions_spec.rb                    [CREATE] Controller tests
```

---

## 📝 File Details

### [CREATE] New Files (9 files)

#### 1. `config/initializers/omniauth.rb`
**Purpose**: Configure OmniAuth middleware for Auth0
**Lines**: ~15
**Dependencies**: Settings.auth0.ruler.*

#### 2. `db/schemas/rulers.schema`
**Purpose**: Database schema for rulers table (Ridgepole format)
**Lines**: ~10
**Dependencies**: None

#### 3. `app/models/ruler.rb`
**Purpose**: Ruler model with validations and Auth0 integration
**Lines**: ~25
**Dependencies**: ApplicationRecord, Sorbet

#### 4. `app/controllers/ruler_area/sessions_controller.rb`
**Purpose**: Handle login, logout, callback actions
**Lines**: ~40
**Dependencies**: RulerArea::ApplicationController

#### 5. `app/views/ruler_area/sessions/new.html.erb`
**Purpose**: Login page UI
**Lines**: ~20
**Dependencies**: UIKit CSS, layout

#### 6. `spec/factories/rulers.rb`
**Purpose**: FactoryBot factory for testing
**Lines**: ~10
**Dependencies**: FactoryBot, FFaker

#### 7. `spec/models/ruler_spec.rb`
**Purpose**: Model unit tests
**Lines**: ~60
**Dependencies**: RSpec, FactoryBot

#### 8. `spec/requests/ruler_area/sessions_spec.rb`
**Purpose**: Controller integration tests
**Lines**: ~80
**Dependencies**: RSpec, OmniAuth test mode

---

### [MODIFY] Existing Files (5 files)

#### 1. `.env.local`
**Changes**: Add 3 new environment variables
**Lines to add**: 3
```bash
AUTH0_RULER_DOMAIN=your-tenant.auth0.com
AUTH0_RULER_CLIENT_ID=your_client_id
AUTH0_RULER_CLIENT_SECRET=your_client_secret
```

#### 2. `Gemfile`
**Changes**: Add 3 new gems
**Lines to add**: 3
```ruby
gem 'omniauth', '~> 2.1'
gem 'omniauth-auth0', '~> 3.1'
gem 'omniauth-rails_csrf_protection', '~> 1.0'
```

#### 3. `config/routes.rb`
**Changes**: Add authentication routes inside `ruler_area` namespace
**Lines to add**: 4
**Location**: Inside `namespace :ruler_area` block (after line 16)
```ruby
get '/auth/auth0/callback', to: 'sessions#create'
get '/auth/failure', to: 'sessions#failure'
get '/login', to: 'sessions#new', as: :login
delete '/logout', to: 'sessions#destroy', as: :logout
```

#### 4. `db/Schemafile`
**Changes**: Require rulers schema
**Lines to add**: 1
**Location**: After `require 'schemas/tenants.schema'` (line 5)
```ruby
require 'schemas/rulers.schema'
```

#### 5. `app/controllers/ruler_area/application_controller.rb`
**Changes**:
- Remove TODO comments (lines 8-25)
- Add authentication methods
**Lines to remove**: ~18
**Lines to add**: ~15
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

#### 6. `app/views/layouts/ruler_area/application.html.erb`
**Changes**: Update navbar right section with user info and logout
**Lines to modify**: ~20
**Location**: Lines 40-45 (navbar-right section)
```erb
<div class="uk-navbar-right">
  <ul class="uk-navbar-nav">
    <% if signed_in? %>
      <li>
        <a href="#">
          <% if current_ruler.avatar_url.present? %>
            <%= image_tag current_ruler.avatar_url, class: 'uk-border-circle', style: 'width: 32px; height: 32px;' %>
          <% end %>
          <%= current_ruler.name || current_ruler.email %>
        </a>
        <div class="uk-navbar-dropdown">
          <ul class="uk-nav uk-navbar-dropdown-nav">
            <li class="uk-nav-header"><%= current_ruler.email %></li>
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

---

## 📊 Summary

| Category | Count |
|----------|-------|
| New Files | 8 |
| Modified Files | 6 |
| **Total Files** | **14** |

| File Type | Count |
|-----------|-------|
| Ruby Models | 1 |
| Ruby Controllers | 1 |
| Ruby Schemas | 1 |
| Ruby Specs | 3 |
| Initializers | 1 |
| Views (ERB) | 1 |
| Configuration | 4 |
| Environment | 1 |
| **Total** | **14** |

---

## 🔍 Code Size Estimation

| Component | Lines of Code |
|-----------|---------------|
| Model | ~25 |
| Controller | ~40 |
| View | ~20 |
| Initializer | ~15 |
| Schema | ~10 |
| Tests | ~150 |
| **Total New Code** | **~260 lines** |

---

## ✅ File Creation Order

Follow this order to avoid dependency issues:

1. ✅ Update `Gemfile` → Run `bundle install`
2. ✅ Create `db/schemas/rulers.schema`
3. ✅ Update `db/Schemafile`
4. ✅ Run `ridgepole:apply` to create table
5. ✅ Create `app/models/ruler.rb`
6. ✅ Create `config/initializers/omniauth.rb`
7. ✅ Update `config/routes.rb`
8. ✅ Create `app/controllers/ruler_area/sessions_controller.rb`
9. ✅ Update `app/controllers/ruler_area/application_controller.rb`
10. ✅ Create `app/views/ruler_area/sessions/new.html.erb`
11. ✅ Update `app/views/layouts/ruler_area/application.html.erb`
12. ✅ Update `.env.local` with Auth0 credentials
13. ✅ Create test files (factories, specs)
14. ✅ Restart application

---

## 🎨 File Templates Location

All file templates are available in:
- **Full Specification**: `RULER_AUTH0_LOGIN_SPEC.md`
- **Quick Start**: `RULER_AUTH0_QUICK_START.md`
- **Checklist**: `RULER_AUTH0_CHECKLIST.md`

---

## 🔗 Related Files (No Changes Needed)

These files are referenced but don't need modification:

- ✓ `config/settings.yml` (Auth0 config already exists at lines 18-21)
- ✓ `app/frontend/entrypoints/ruler_area/application.ts` (No JS changes needed)
- ✓ `app/assets/images/ruler_area/haguruma-logo.svg` (Used in login page)
- ✓ `app/models/application_record.rb` (Ruler inherits from this)
- ✓ `app/models/tenant.rb` (Reference for model structure)

---

**Last Updated**: 2025-10-17
**Document Version**: 1.0
