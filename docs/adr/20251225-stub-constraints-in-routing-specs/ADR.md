# Stub Domain Constraints in Routing Specs

## Status

Accepted

## Context

This system uses domain constraints in `routes.rb` to serve different routes for different domains.

```ruby
constraints Constraints::AdminDomainConstraint.new do
  draw :admin
end
```

However, RSpec's `route_to` matcher has a known issue where it does not properly evaluate custom constraint objects.

### Problem Details

RSpec's `route_to` matcher is a wrapper around Rails' `assert_recognizes`. Since `assert_recognizes` does not pass a complete request object to the constraint object's `matches?` method, domain-based constraints are not properly evaluated.

This issue has been reported in the RSpec Rails project over many years:

- [rspec/rspec-rails#1699](https://github.com/rspec/rspec-rails/issues/1699) - `route_to` spec failing to recognize route constraints
- [rspec/rspec-rails#239](https://github.com/rspec/rspec-rails/issues/239) - Constraints for routes not recognized in RSpec
- [rspec/rspec-rails#712](https://github.com/rspec/rspec-rails/issues/712) - `route_to` matcher doesn't give query params to advanced constraint instance
- [rails/rails#2781](https://github.com/rails/rails/issues/2781) - Route constraint matcher class doesn't receive adequate request object during tests

As a result, routing specs like the following fail:

```ruby
expect(get: '/admin/contents').to route_to(
  controller: 'admin_area/contents/root',
  action: 'index',
)
# => No route matches "/admin/contents"
```

## Decision

Use `allow_any_instance_of` in routing specs to stub domain constraints.

```ruby
RSpec.describe 'AdminArea::Contents routing' do
  before do
    allow_any_instance_of(Constraints::AdminDomainConstraint).to receive(:matches?).and_return(true)
  end

  # ...
end
```

### Options Considered

#### 1. Conditional branching in routes.rb for test environment

```ruby
if Rails.env.test?
  draw :admin
else
  constraints Constraints::AdminDomainConstraint.new do
    draw :admin
  end
end
```

**Reason for rejection**: Test-specific verbose code should not be introduced into routes.rb. Complicating production code for test convenience degrades maintainability.

#### 2. Delete routing specs

Since domain-constrained routes cannot be tested this way, delete the routing specs entirely.

**Reason for rejection**: It is common practice to design only the URL (path) and its routing destination (controller and action) first, then implement the actual processing later. For example, even if static, one might first implement a stub endpoint that only defines the response format to return to the frontend. In such cases, one wants to write routing specs rather than request specs, so deleting routing specs is not appropriate.

#### 3. Switch to request specs

Test with request specs that use actual HTTP requests.

**Reason for rejection**: For the same reasons as option 2, there are situations where routing specs are preferred. Additionally, request specs require controller implementation, making it impossible to test routing in advance.

#### 4. Mock constraints within routing specs (Adopted)

Use `allow_any_instance_of` to stub the constraint's `matches?` method.

**Reason for adoption**: Stubbing constraints is contained within test code and does not affect production code. It achieves the original purpose of routing specs (verifying URL to controller/action mapping).

## Consequences

### Positive

- Routing specs can be maintained
- No changes required to production code (routes.rb, constraint classes)
- Test intent is clear (it's visible within the spec that constraints are being stubbed)
- Development workflow of testing URL design first can be maintained

### Negative

- `allow_any_instance_of` is not a recommended practice in RSpec best practices
  - However, in this case, since constraint objects are created internally within routing, it is difficult to mock them by other means
- The behavior of domain constraints themselves is not tested in routing specs
  - If needed, unit tests for constraint classes can be created separately
