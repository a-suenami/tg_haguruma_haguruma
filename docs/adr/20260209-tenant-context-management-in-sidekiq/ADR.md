# ADR: Safety of Tenant Context Management in Sidekiq Jobs

- **Date**: 2026-02-09
- **Status**: Decided
- **Decision Makers**: Akira Suenami

## Context

In EventBridge event processing (`IdpProcessor`), the `tenant_id` must be extracted from the event's `source`, set as `Tenant.current_id`, and then each Handler must be invoked.

Internally, `Tenant.current_id` stores its value in `RequestStore.store[:current_tenant]`, and the `default_scope` in the `Multitenancy` concern references this value to implement multi-tenant scoping.

```ruby
# Multitenancy concern
def default_scope
  where(tenant_id: RequestStore.store[:current_tenant]) if RequestStore.store[:current_tenant].present?
end
```

The following questions arose:

1. Is `RequestStore` thread-safe in Sidekiq's thread pool environment?
2. Is the save/restore pattern for tenant context safe?
3. Are there pitfalls with the combination of ensure blocks and early returns?

## Decision

Adopt the `RequestStore` + save/restore pattern.

### Thread Safety of RequestStore

`RequestStore` is a thread-local storage mechanism based on `Thread.current`. Since each thread has its own independent storage area, data does not interfere between different threads.

Sidekiq operates on a thread pool model, executing one job at a time per thread. Two jobs never run simultaneously on the same thread.

Additionally, the `request_store-sidekiq` gem is integrated as Sidekiq middleware, which automatically clears `RequestStore` before and after each job execution. This prevents the tenant context from one job leaking into the next.

### Save/Restore Pattern

When called as a Sidekiq job, `request_store-sidekiq` clears the store at job start, so `previous_tenant_id` will almost always be `nil`. The save/restore pattern is defensive coding that guards against the unlikely case where a tenant is already set in the context (e.g., during tests or nested invocations).

```ruby
def process(message)
  # ...
  previous_tenant_id = Tenant.current_id
  begin
    Tenant.current_id = @tenant_id
    dispatch(message.detail_type, detail)
  ensure
    if previous_tenant_id
      Tenant.current_id = previous_tenant_id
    else
      RequestStore.store.delete(:current_tenant)
    end
  end
end
```

When restoring in the ensure block, if `previous_tenant_id` is `nil` (meaning no tenant was set), we explicitly clear with `RequestStore.store.delete(:current_tenant)` rather than `Tenant.current_id = nil`. This is because `Tenant.current_id = nil` internally results in `nil.to_s` producing an empty string `""` that would remain in the store.

### Ensure Blocks and Early Return Considerations

An ensure block executes even when an early return occurs within the method. The assignment of `previous_tenant_id` is placed immediately before the `begin` block that the ensure protects, so that an early return before the assignment does not cause the ensure block to produce unintended side effects.

```ruby
# BAD: If early return occurs, previous_tenant_id remains nil when ensure runs, deleting the tenant
def process(message)
  return unless detail.is_a?(Hash)          # <- If return happens here...
  previous_tenant_id = Tenant.current_id    # <- This is never executed
  Tenant.current_id = @tenant_id
  # ...
ensure
  RequestStore.store.delete(:current_tenant) if previous_tenant_id.nil?  # <- ensure still runs
end

# GOOD: Place begin...ensure after guard clauses
def process(message)
  return unless detail.is_a?(Hash)
  previous_tenant_id = Tenant.current_id
  begin
    Tenant.current_id = @tenant_id
    # ...
  ensure
    # previous_tenant_id is guaranteed to be assigned
  end
end
```

## Rationale

### Why RequestStore Was Chosen

- The existing Rails pattern (`Multitenancy` concern) already depends on `RequestStore`, so using it maintains consistency rather than introducing a new mechanism
- The `request_store-sidekiq` gem guarantees safe operation in the Sidekiq environment
- As a thread-local storage mechanism, no locks are required and there is no performance impact

### Why the Save/Restore Pattern Was Chosen

- It avoids destroying the calling context's tenant context during tests or future nested invocations
- While redundant when used solely within Sidekiq (since `request_store-sidekiq` handles cleanup), the cost of this defensive design is low

### Why begin...ensure Separation Was Chosen

- With a method-level ensure, an early return from a guard clause causes `previous_tenant_id` to be treated as `nil` (uninitialized), which leads to unintended deletion of the tenant context
- Using an explicit `begin...ensure...end` block makes the protected scope clear, structurally guaranteeing that tenant context setup and teardown are paired

## Impact

- Since this depends on `RequestStore` (`Thread.current`), it cannot be used as-is with different concurrency models such as Ractor
- When applying the same pattern in other Processors, the same `begin...ensure` structure must be followed

## Related

- `app/services/eventbridge/processors/idp_processor.rb` -- Implementation of this pattern
- `app/models/concerns/multitenancy.rb` -- Tenant scoping via `default_scope`
- `app/models/tenant.rb` -- Definition of `Tenant.current_id` / `Tenant.current_id=`
