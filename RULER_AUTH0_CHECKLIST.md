# Ruler Area Auth0 Login - Implementation Checklist

## 📋 Pre-Implementation

### Auth0 Setup
- [ ] Create Auth0 Application (Regular Web Application)
- [ ] Configure Callback URLs:
  - Development: `http://localhost:3000/ruler/auth/auth0/callback`
  - Production: `https://ruler.yourdomain.com/ruler/auth/auth0/callback`
- [ ] Configure Logout URLs:
  - Development: `http://localhost:3000/ruler/login`
  - Production: `https://ruler.yourdomain.com/ruler/login`
- [ ] Copy credentials:
  - [ ] Domain (e.g., `your-tenant.auth0.com`)
  - [ ] Client ID
  - [ ] Client Secret
- [ ] Update `.env.local` with Auth0 credentials

---

## 🔧 Implementation Tasks

### 1. Dependencies (15 min)
- [ ] Add to `Gemfile`:
  ```ruby
  gem 'omniauth', '~> 2.1'
  gem 'omniauth-auth0', '~> 3.1'
  gem 'omniauth-rails_csrf_protection', '~> 1.0'
  ```
- [ ] Run: `source env.sh && bundle install`

### 2. Database Schema (20 min)
- [ ] Create `db/schemas/rulers.schema` with rulers table definition
- [ ] Update `db/Schemafile` to require rulers schema
- [ ] Run: `source env.sh && bundle exec rails ridgepole:apply`
- [ ] Verify table created: Check PostgreSQL or run Rails console

### 3. Model (30 min)
- [ ] Create `app/models/ruler.rb`
- [ ] Add validations (email, auth0_account_id)
- [ ] Implement `self.from_omniauth` method
- [ ] Add Sorbet type signatures

### 4. Configuration (15 min)
- [ ] Create `config/initializers/omniauth.rb`
- [ ] Configure Auth0 provider with Settings values
- [ ] Set callback_path and authorize_params

### 5. Routes (10 min)
- [ ] Update `config/routes.rb`
- [ ] Add authentication routes:
  - [ ] Login page: `GET /ruler/login`
  - [ ] Logout: `DELETE /ruler/logout`
  - [ ] Callback: `GET /ruler/auth/auth0/callback`
  - [ ] Failure: `GET /ruler/auth/failure`

### 6. Sessions Controller (45 min)
- [ ] Create `app/controllers/ruler_area/sessions_controller.rb`
- [ ] Implement `new` action (login page)
- [ ] Implement `create` action (handle callback)
- [ ] Implement `destroy` action (logout)
- [ ] Implement `failure` action (error handling)
- [ ] Add `skip_before_action :authenticate!` for public actions

### 7. Application Controller Update (20 min)
- [ ] Update `app/controllers/ruler_area/application_controller.rb`
- [ ] Enable `before_action :authenticate!`
- [ ] Add `helper_method :current_ruler, :signed_in?`
- [ ] Implement `authenticate!` method
- [ ] Implement `current_ruler` method
- [ ] Implement `signed_in?` method
- [ ] Remove all authentication TODO comments

### 8. Login View (30 min)
- [ ] Create `app/views/ruler_area/sessions/new.html.erb`
- [ ] Add Haguruma logo
- [ ] Add "Login with Auth0" button (POST method)
- [ ] Add `data: { turbo: false }` attribute
- [ ] Style with UIKit classes
- [ ] Add flash message display

### 9. Layout Update (30 min)
- [ ] Update `app/views/layouts/ruler_area/application.html.erb`
- [ ] Add user info in navbar (avatar, name, email)
- [ ] Add dropdown menu with:
  - [ ] User email header
  - [ ] Account settings link (placeholder)
  - [ ] Logout button
- [ ] Add conditional rendering based on `signed_in?`

### 10. Testing (60 min)
- [ ] Create `spec/factories/rulers.rb`
- [ ] Create `spec/models/ruler_spec.rb`:
  - [ ] Validation tests
  - [ ] `from_omniauth` tests (create & update)
- [ ] Create `spec/requests/ruler_area/sessions_spec.rb`:
  - [ ] Login page test
  - [ ] Callback test
  - [ ] Logout test
  - [ ] Redirect when already signed in
- [ ] Run all tests: `source env.sh && bundle exec rspec`

---

## ✅ Verification

### Manual Testing
- [ ] Visit `http://localhost:3000/ruler` → Should redirect to login
- [ ] Visit `http://localhost:3000/ruler/login` → See login page
- [ ] Click "Login with Auth0" → Redirect to Auth0
- [ ] Login with Auth0 account → Redirect back to `/ruler`
- [ ] See user info in navbar (name, email, avatar)
- [ ] Click user dropdown → See logout button
- [ ] Click logout → Redirect to login page
- [ ] Verify session cleared (can't access `/ruler` without login)

### Code Quality
- [ ] Run Sorbet: `srb tc .` → No errors
- [ ] Run RuboCop: `bundle exec rubocop -A` → Auto-fix issues
- [ ] All RSpec tests pass
- [ ] No N+1 queries (check with Bullet gem if enabled)

### Security Checks
- [ ] Auth0 credentials in `.env.local` (not committed to git)
- [ ] CSRF protection enabled (omniauth-rails_csrf_protection)
- [ ] Session timeout configured (optional)
- [ ] Secure cookies in production (https only)
- [ ] No sensitive data in logs

---

## 🐛 Troubleshooting Checklist

If login doesn't work:
- [ ] Check Auth0 callback URLs match exactly
- [ ] Verify `.env.local` has correct credentials
- [ ] Check Rails logs: `docker-compose logs -f app`
- [ ] Verify OmniAuth initializer loaded: `Rails.configuration.middleware`
- [ ] Test with Auth0 test user account
- [ ] Check browser console for JavaScript errors
- [ ] Verify `data: { turbo: false }` on login button
- [ ] Check session cookie is set in browser devtools

If redirect loop occurs:
- [ ] Verify `skip_before_action` in SessionsController
- [ ] Check `authenticate!` logic in ApplicationController
- [ ] Ensure session is set in `create` action
- [ ] Check `current_ruler` method returns correctly

---

## 📊 Time Estimate

| Task | Estimated Time |
|------|----------------|
| Auth0 Setup | 30 min |
| Dependencies | 15 min |
| Database Schema | 20 min |
| Model | 30 min |
| Configuration | 15 min |
| Routes | 10 min |
| Sessions Controller | 45 min |
| Application Controller | 20 min |
| Login View | 30 min |
| Layout Update | 30 min |
| Testing | 60 min |
| Manual Testing & Debug | 30 min |
| **Total** | **5 hours 15 min** |

---

## 📝 Completion Criteria

All items below must be checked:

- [ ] All code files created
- [ ] All tests passing
- [ ] Sorbet type checking passes
- [ ] RuboCop linting passes
- [ ] Manual login flow tested successfully
- [ ] Logout flow tested successfully
- [ ] Authentication protection verified
- [ ] Documentation complete
- [ ] Code reviewed (if applicable)
- [ ] Ready for merge/deployment

---

**Status**: ⬜ Not Started | 🟡 In Progress | ✅ Complete
**Developer**: _____________
**Start Date**: _____________
**Target Completion**: _____________
**Actual Completion**: _____________
