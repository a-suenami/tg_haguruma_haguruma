# ADR: User Area Authentication Architecture

- **Date**: 2025-12-25
- **Status**: Decided

## Context

The User Area requires OAuth-based authentication. This is a multi-tenant system where each tenant has its own IdP (Identity Provider).

There are two possible approaches for implementing the authentication flow:

### 1. Using OmniAuth

OmniAuth is a Rack middleware that abstracts communication with OAuth providers. It automatically handles the authorization code-to-token exchange and stores the result in `request.env['omniauth.auth']`.

**Advantages:**
- Concise configuration
- Supports many OAuth providers
- Simple callback handling

**Disadvantages:**
- Requires routing configuration since it operates as Rack middleware
- Additional configuration needed to dynamically switch providers in a multi-tenant setup
- Implementation pattern differs from API authentication

### 2. Using Manual Token Exchange

Receive the authorization code and use HTTP requests within a service class to access the token endpoint.

**Advantages:**
- Same pattern as API authentication (implementation consistency)
- Dynamic IdP switching in a multi-tenant setup feels natural
- Can reuse existing services (`VerifyIdTokenService`)

**Disadvantages:**
- Token exchange logic must be implemented in-house

## Decision

**Adopt the manual token exchange approach.**

## Rationale

1. **Implementation consistency with the API**: The existing API authentication already uses manual token exchange; adopting the same pattern for the User Area improves maintainability
2. **Multi-tenant support**: Retrieving each tenant's IdP information from the database and performing token exchange dynamically is a natural fit for this design
3. **Reuse of existing infrastructure**: `Auth::IdPlatform::VerifyIdTokenService` and `AuthApi::IdPlatform` can be reused as-is

### Implementation Overview

A new service `Auth::IdPlatform::ExchangeCodeService` is created to implement the following flow:

1. `SessionsController#create`: Redirect to the OAuth authorization URL (with a state parameter)
2. User authenticates at the IdP
3. `SessionsController#callback`: Receive the authorization code
4. `ExchangeCodeService`: Exchange the authorization code for tokens
5. `VerifyIdTokenService`: Verify the ID token
6. Retrieve or create the user and establish a session

## Impact

### Positive

- Authentication patterns are unified across the API and User Area
- The existing `VerifyIdTokenService` can be reused without modification
- Dynamic IdP switching in a multi-tenant setup can be implemented naturally
- No OmniAuth configuration or dependency required

### Negative

- Token exchange logic must be implemented and maintained in-house
- Additional features provided by OmniAuth (e.g., absorbing subtle differences between providers) are not available
