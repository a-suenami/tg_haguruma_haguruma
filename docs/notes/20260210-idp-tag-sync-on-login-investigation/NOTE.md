# IDP Tag Sync (On Login) Investigation Note

## Background

We released a feature to include `tags` in auth-platform's ID token and sync them on the Haguruma side at login time.
However, when testing in the staging environment, authorization tags were not synced to Haguruma.

## Architecture

### auth-platform Side

- Added `integration_enabled_tags` to the `user` claim in the ID token
- Set `json[:tags]` unconditionally inside the `claim :user` block in `doorkeeper_openid_connect.rb`

```ruby
claim :user, response: :id_token do |resource_owner, scope|
  json = {}
  # ... scope-dependent fields ...
  json[:tags] = resource_owner.integration_enabled_tags.map do |tag|
    { id: tag.id, name: tag.name }
  end
  json
end
```

### Haguruma Side

- Calls `Users::SyncIdpTagsService` during the login callback
- Extracts tags from `user.tags` in the ID token and creates `ContentAuthorizationTag` and `UserTag` records

```ruby
# sessions_controller.rb
idp_tags = payload.dig('user', 'tags') || []
Users::SyncIdpTagsService.new(user:, tags: idp_tags).execute if idp_tags.present?
```

## Investigation Results

### Symptoms

- Login succeeds (302 redirect, no exceptions)
- `ContentAuthorizationTag` records not created in the DB
- Running `SyncIdpTagsService` manually from Haguruma's Rails console works correctly

### Root Cause: doorkeeper-openid_connect Scope Resolution Logic

The `OauthProvider.scopes` in Haguruma was set to `openid` only, causing the `user` claim itself to be omitted from the ID token entirely.

#### Details

The `Claim` class in doorkeeper-openid_connect (1.8.7) automatically assigns a default scope when none is explicitly specified:

```ruby
# doorkeeper-openid_connect lib/doorkeeper/openid_connect/claims/claim.rb
def initialize(options = {})
  @scope = options[:scope].to_sym if options[:scope]

  # Check if included in Standard Claims (profile, email, address, phone)
  @scope ||= STANDARD_CLAIMS.find do |_scope, claims|
    claims.include? @name
  end.try(:first)

  # Fallback: default to profile scope
  @scope ||= :profile
end
```

Then `ClaimsBuilder.generate` determines whether to include the claim in the output:

```ruby
# doorkeeper-openid_connect lib/doorkeeper/openid_connect/claims_builder.rb
def self.generate(access_token, response)
  Doorkeeper::OpenidConnect.configuration.claims.to_h.map do |name, claim|
    if access_token.scopes.exists?(claim.scope) && claim.response.include?(response)
      [name, claim.generator.call(resource_owner, access_token.scopes, access_token)]
    end
  end.compact.to_h
end
```

Since `claim :user` does not specify a scope:

1. `:user` is not included in `STANDARD_CLAIMS` → `nil`
2. Falls back to **`:profile` scope as default**
3. `access_token.scopes.exists?(:profile)` is `false` → **the entire `user` claim is omitted**

As a result, `payload.dig('user', 'tags')` was `nil`, and `SyncIdpTagsService` was never called.

### Solution

Add `profile` to Haguruma's `OauthProvider.scopes`. Minimum required scopes:

```
openid profile
```

To retrieve all fields:

```
openid uid email name profile phone_number contact delivery_address
```

## Notes

- `normal_claim` and `claim` are aliased to the same method in doorkeeper-openid_connect 1.8.7
- Even if `scope: nil` is explicitly passed to `claim :user`, the fallback still sets `:profile`
- If you want to make the `user` claim scope-independent on the auth-platform side, be aware of the `Claim` default scope behavior. `tenant_id` is defined with `normal_claim :tenant_id`, but since the name is not included in OIDC Standard Claims, it also defaults to `:profile`. The fact that `tenant_id` appeared in the token was only because Haguruma happened to request the `profile` scope

## Related

- auth-platform branch: `feature/id-token-include-tags`
- Haguruma tag sync MR: https://git.l.twogate.net/haguruma/haguruma/-/merge_requests/213
- Haguruma debug logging MR: https://git.l.twogate.net/haguruma/haguruma/-/merge_requests/218
