# Ruler Area - Auth0 Login Implementation

> **Task**: Implement secure authentication for Haguruma Ruler Area using Auth0

---

## 📚 Documentation Overview

This folder contains complete documentation for implementing Auth0 login functionality for the Ruler Area. Choose the document that best fits your needs:

### 📖 Available Documents

| Document | Purpose | For Whom | Read Time |
|----------|---------|----------|-----------|
| **[RULER_AUTH0_LOGIN_SPEC.md](./RULER_AUTH0_LOGIN_SPEC.md)** | Complete technical specification with all code samples | Developers (detailed implementation) | 30-40 min |
| **[RULER_AUTH0_QUICK_START.md](./RULER_AUTH0_QUICK_START.md)** | Quick reference with minimal code snippets | Developers (experienced with Auth0) | 5-10 min |
| **[RULER_AUTH0_CHECKLIST.md](./RULER_AUTH0_CHECKLIST.md)** | Step-by-step checklist for tracking progress | Project Managers / Developers | 5 min |
| **[RULER_AUTH0_FILE_STRUCTURE.md](./RULER_AUTH0_FILE_STRUCTURE.md)** | File structure and code size estimates | Tech Leads / Architects | 10 min |

---

## 🎯 What This Implements

### Current State (Before)
- ✗ No authentication on Ruler Area
- ✗ Anyone can access `/ruler` routes
- ✗ No user session management
- ✗ TODO comments for authentication

### Target State (After)
- ✅ Secure Auth0 login for Ruler Area
- ✅ Session-based authentication
- ✅ User info display (name, email, avatar)
- ✅ Logout functionality
- ✅ Protected routes (redirect to login if not authenticated)
- ✅ Full test coverage

---

## 🚀 Quick Start

### For Project Managers / Team Leads

1. **Read**: [RULER_AUTH0_CHECKLIST.md](./RULER_AUTH0_CHECKLIST.md)
2. **Setup Auth0**: Follow "Pre-Implementation" section
3. **Assign Task**: Provide checklist to developer
4. **Track Progress**: Use checklist to monitor completion
5. **Estimate**: ~5-6 hours for experienced developer

### For Developers (First Time)

1. **Read**: [RULER_AUTH0_LOGIN_SPEC.md](./RULER_AUTH0_LOGIN_SPEC.md) (Full spec)
2. **Reference**: [RULER_AUTH0_FILE_STRUCTURE.md](./RULER_AUTH0_FILE_STRUCTURE.md)
3. **Track**: Use [RULER_AUTH0_CHECKLIST.md](./RULER_AUTH0_CHECKLIST.md)
4. **Start Coding**: Follow implementation steps in spec

### For Developers (Experienced)

1. **Scan**: [RULER_AUTH0_QUICK_START.md](./RULER_AUTH0_QUICK_START.md)
2. **Copy-Paste**: Code snippets from quick start
3. **Track**: Mark items in [RULER_AUTH0_CHECKLIST.md](./RULER_AUTH0_CHECKLIST.md)
4. **Verify**: Run manual tests from checklist

---

## 📋 Prerequisites

### Knowledge Required
- ✅ Ruby on Rails 8.x
- ✅ PostgreSQL
- ✅ OAuth 2.0 / OIDC concepts (basic understanding)
- ✅ RSpec testing
- ✅ Sorbet type system (optional but recommended)

### Tools Required
- ✅ Auth0 Account (free tier is sufficient)
- ✅ Docker & Docker Compose (for development environment)
- ✅ Text editor / IDE

### Access Required
- ✅ Auth0 Dashboard access (to create application)
- ✅ Repository write access
- ✅ `.env.local` file editing permission

---

## 🔐 Auth0 Setup (Before Coding)

### Required Information

You need to create an Auth0 Application and obtain:

| Field | Example | Where to Find |
|-------|---------|---------------|
| **Domain** | `your-tenant.auth0.com` | Auth0 Dashboard → Applications → Settings |
| **Client ID** | `abc123xyz...` | Auth0 Dashboard → Applications → Settings |
| **Client Secret** | `secret123...` | Auth0 Dashboard → Applications → Settings |

### Configuration Steps

1. Login to [Auth0 Dashboard](https://manage.auth0.com/)
2. Create **Regular Web Application**
3. Configure:
   - **Allowed Callback URLs**: `http://localhost:3000/ruler/auth/auth0/callback`
   - **Allowed Logout URLs**: `http://localhost:3000/ruler/login`
   - **Allowed Web Origins**: `http://localhost:3000`
4. Save credentials to `.env.local`

**Detailed instructions**: See [RULER_AUTH0_LOGIN_SPEC.md - Auth0 Configuration](./RULER_AUTH0_LOGIN_SPEC.md#-auth0-configuration)

---

## 🏗️ Implementation Summary

### What Gets Created

| Component | Files | Lines of Code |
|-----------|-------|---------------|
| **Models** | 1 file | ~25 lines |
| **Controllers** | 1 file | ~40 lines |
| **Views** | 1 file | ~20 lines |
| **Database Schema** | 1 file | ~10 lines |
| **Configuration** | 1 file | ~15 lines |
| **Tests** | 3 files | ~150 lines |
| **Total** | **8 new files** | **~260 lines** |

### What Gets Modified

| File | Changes |
|------|---------|
| `Gemfile` | Add 3 gems |
| `config/routes.rb` | Add 4 routes |
| `db/Schemafile` | Add 1 require statement |
| `app/controllers/ruler_area/application_controller.rb` | Enable authentication (~15 lines) |
| `app/views/layouts/ruler_area/application.html.erb` | Add user info/logout (~20 lines) |
| `.env.local` | Add 3 environment variables |

**Total Modified**: 6 files

---

## ⏱️ Time Estimates

### Development Time

| Developer Experience | Estimated Time |
|---------------------|----------------|
| **Senior** (familiar with Auth0 & Rails) | 3-4 hours |
| **Mid-level** (some OAuth experience) | 5-6 hours |
| **Junior** (first time with OAuth) | 8-10 hours |

### Breakdown by Phase

| Phase | Tasks | Time |
|-------|-------|------|
| **Setup** | Auth0 config, gems, environment | 30-45 min |
| **Backend** | Models, controllers, routes | 1.5-2 hours |
| **Frontend** | Views, layout updates | 45-60 min |
| **Testing** | Write & run tests | 1-1.5 hours |
| **Debug & QA** | Manual testing, fixes | 30-60 min |
| **Total** | | **4.5-6 hours** |

---

## ✅ Acceptance Criteria

### Functional Requirements
- [ ] Ruler can login via Auth0
- [ ] Ruler info displayed in navbar (name, email, avatar)
- [ ] Ruler can logout
- [ ] Unauthenticated users redirected to login
- [ ] Session persists across page refreshes
- [ ] Error messages shown for failed auth

### Technical Requirements
- [ ] All tests pass (`rspec`)
- [ ] Type checking passes (`srb tc .`)
- [ ] Code linting passes (`rubocop -A`)
- [ ] Database migrations applied successfully
- [ ] No security vulnerabilities

### User Experience
- [ ] Login flow is smooth (< 5 clicks)
- [ ] UI matches Ruler Area design (UIKit)
- [ ] Error messages are clear and in Japanese
- [ ] Logout redirects to login page

---

## 🧪 Testing

### Manual Testing Steps

```bash
# 1. Start application
docker-compose up -d

# 2. Visit Ruler Area
open http://localhost:3000/ruler

# Expected: Redirect to login page

# 3. Click "Login with Auth0"
# Expected: Redirect to Auth0 login

# 4. Enter Auth0 credentials
# Expected: Redirect back to /ruler (tenants list)

# 5. Check navbar
# Expected: See user name/email and avatar

# 6. Click logout
# Expected: Redirect to login page, session cleared
```

### Automated Testing

```bash
# Run all tests
source env.sh && bundle exec rspec

# Run specific tests
source env.sh && bundle exec rspec spec/models/ruler_spec.rb
source env.sh && bundle exec rspec spec/requests/ruler_area/sessions_spec.rb

# Type checking
srb tc .

# Linting
bundle exec rubocop -A
```

---

## 🐛 Troubleshooting

### Common Issues

| Issue | Solution | Document Reference |
|-------|----------|-------------------|
| "Callback URL mismatch" | Check Auth0 dashboard URLs | [SPEC - Auth0 Configuration](./RULER_AUTH0_LOGIN_SPEC.md#-auth0-configuration) |
| "CSRF token error" | Ensure `omniauth-rails_csrf_protection` gem installed | [SPEC - Dependencies](./RULER_AUTH0_LOGIN_SPEC.md#1-dependencies-gemfile) |
| "Infinite redirect loop" | Check `skip_before_action` in SessionsController | [CHECKLIST - Troubleshooting](./RULER_AUTH0_CHECKLIST.md#-troubleshooting-checklist) |
| "Session not persisting" | Verify session configuration | [SPEC - Common Issues](./RULER_AUTH0_LOGIN_SPEC.md#-common-issues--solutions) |

**Full troubleshooting guide**: [RULER_AUTH0_LOGIN_SPEC.md - Common Issues](./RULER_AUTH0_LOGIN_SPEC.md#-common-issues--solutions)

---

## 📞 Support & References

### Internal Documentation
- [CLAUDE.md](./CLAUDE.md) - Project overview and development guidelines
- [README.md](./README.md) - Project README

### External Resources
- [Auth0 Rails Quickstart](https://auth0.com/docs/quickstart/webapp/rails)
- [OmniAuth Auth0 Strategy](https://github.com/auth0/omniauth-auth0)
- [Rails Session Management](https://guides.rubyonrails.org/action_controller_overview.html#session)
- [Ridgepole Documentation](https://github.com/ridgepole/ridgepole)

### Getting Help
1. Check [RULER_AUTH0_LOGIN_SPEC.md - Troubleshooting](./RULER_AUTH0_LOGIN_SPEC.md#-common-issues--solutions)
2. Review Auth0 documentation
3. Search existing issues in project repository
4. Ask in team Slack channel

---

## 🎓 Learning Resources

### For Developers New to OAuth/Auth0
- [OAuth 2.0 Simplified](https://aaronparecki.com/oauth-2-simplified/)
- [Auth0 How It Works](https://auth0.com/docs/get-started/auth0-overview)
- [OpenID Connect Explained](https://openid.net/connect/)

### For Developers New to Ridgepole
- [Ridgepole README](https://github.com/ridgepole/ridgepole)
- Project example: `db/schemas/tenants.schema`

### For Developers New to Sorbet
- [Sorbet Quick Start](https://sorbet.org/docs/overview)
- Project example: `app/models/tenant.rb`

---

## 📊 Project Impact

### Files Changed
- **New Files**: 8
- **Modified Files**: 6
- **Total Files Affected**: 14

### Code Added
- **Application Code**: ~110 lines
- **Test Code**: ~150 lines
- **Total**: ~260 lines

### Database Changes
- **New Tables**: 1 (`rulers`)
- **New Columns**: 6
- **New Indexes**: 2

---

## ✨ Features Delivered

After implementation, Rulers will be able to:

1. ✅ **Login** using Auth0 (Google, GitHub, username/password, etc.)
2. ✅ **View** their profile information in the navbar
3. ✅ **Logout** securely from the system
4. ✅ **Access** protected Ruler Area routes only when authenticated
5. ✅ **Experience** seamless session management

---

## 🚦 Status

**Current Status**: 📝 Documentation Complete - Ready for Implementation

**Next Steps**:
1. Developer reviews [RULER_AUTH0_LOGIN_SPEC.md](./RULER_AUTH0_LOGIN_SPEC.md)
2. Project Manager sets up Auth0 application
3. Developer implements using [RULER_AUTH0_CHECKLIST.md](./RULER_AUTH0_CHECKLIST.md)
4. QA tests using acceptance criteria
5. Deploy to staging environment
6. Production deployment

---

## 📅 Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-17 | Claude Code | Initial documentation |

---

**Questions?** Refer to the detailed specification: [RULER_AUTH0_LOGIN_SPEC.md](./RULER_AUTH0_LOGIN_SPEC.md)

**Ready to start?** Use this checklist: [RULER_AUTH0_CHECKLIST.md](./RULER_AUTH0_CHECKLIST.md)

**Need quick reference?** See: [RULER_AUTH0_QUICK_START.md](./RULER_AUTH0_QUICK_START.md)
