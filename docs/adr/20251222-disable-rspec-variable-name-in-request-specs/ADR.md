# ADR: Disable RSpec/VariableName in spec/requests

- **Date**: 2025-12-22
- **Status**: Decided

## Context

In OpenAPI spec tests using rswag, HTTP header names must be used directly as variable names via `let`, such as `let(:Authorization)`.

```ruby
let(:Authorization) { "Bearer #{session_token.id}" }
```

However, the RuboCop `RSpec/VariableName` rule requires variable names to be in snake_case, which flags PascalCase variable names like `Authorization` as violations.

Due to the way rswag works, the `let` variable name must match the header name exactly. Changing it to snake_case would break the tests.

## Decision

Disable the `RSpec/VariableName` rule for `spec/requests/**/*` in `.rubocop.yml`.

```yaml
RSpec/VariableName:
  Exclude:
    - 'spec/requests/**/*'
```

## Rationale

This is the simplest approach that avoids scattering individual `rubocop:disable` comments across files while keeping rswag tests functional with their required PascalCase header variable names.

## Impact

### Positive

- HTTP headers in rswag tests can be set naturally
- No need to add `rubocop:disable` comments to individual files or lines
- Consistent rule application removes ambiguity when writing new request specs

### Negative

- Non-snake_case variable names are permitted under `spec/requests`, which could allow unintended naming conventions to creep in
  - In practice, PascalCase is only used for HTTP header names, so the impact is limited
