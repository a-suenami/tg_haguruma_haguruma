# frozen_string_literal: true

# ==============================================================================
# Rulers & Auth0 Accounts
# ==============================================================================

Rails.logger.debug '👑 Seeding Rulers & Auth0 Accounts...'

# -----------------------------------------------------------------------------
# Production Ruler
# -----------------------------------------------------------------------------
RULER_AUTH0_UID = 'auth0|68f1fd7285c3c569694ab97e'
RULER_EMAIL = 'thi.tram@twogate.com'
RULER_NAME = 'Thi Tram'

# Create or update Auth0Account
auth0_account = Auth0Account.find_or_initialize_by(uid: RULER_AUTH0_UID)
auth0_account.email = RULER_EMAIL

if auth0_account.save
  Rails.logger.debug { "  ✅ Auth0Account: #{auth0_account.email}" }
else
  Rails.logger.debug { "  ❌ Failed: #{auth0_account.errors.full_messages.join(', ')}" }
  exit 1
end

# Create or update Ruler
ruler = Ruler.find_or_initialize_by(name: RULER_NAME)

if ruler.save
  Rails.logger.debug { "  ✅ Ruler: #{ruler.name}" }
else
  Rails.logger.debug { "  ❌ Failed: #{ruler.errors.full_messages.join(', ')}" }
  exit 1
end

# Link them
Ruler::Auth0Account.find_or_create_by!(
  ruler:,
  auth0_account:,
)

Rails.logger.debug '  ✅ Linked Ruler ↔ Auth0Account'
