# ADR: Adopting seed-fu for Seed Data Management

- **Date**: 2025-11-19
- **Status**: Decided
- **Decision Makers**: Akira Suenami, Thi Tram

## Context

### Background

Using the standard Rails `db/seeds.rb` to manage master data and test data has the following issues:

1. **No idempotency**: Running it multiple times creates duplicate data
2. **Single file**: Difficult to separate data by environment
3. **Procedural**: Cannot define data declaratively

### Requirements

1. Running multiple times always produces the same result (idempotency)
2. Ability to load different data per environment (development/staging/production)
3. Easy to add and update data

## Decision

**Adopt the seed-fu gem and consolidate seed data management under the `db/fixtures/` directory.**

## Rationale

1. **Idempotency**: The `seed` method provides constraint-based record management that prevents duplicates regardless of how many times it is run
2. **Environment separation**: Data can be managed per environment using `db/fixtures/{environment}/`
3. **Declarative**: Supports declarative data definitions with constraint specification

### Directory Structure

```
db/fixtures/
  _shared/              # Shared across all environments
    by_tenant/          # Per-tenant data
      yokikotokiku/
        logo.svg
        key_visual.png
        theme.yml
  development/          # Development environment only
  staging/              # Staging environment only
  production/           # Production environment only
```

### Migration Plan

- `db/seeds/` will be deprecated in the long term
- Existing `db/seeds/*.rb` files will be migrated to `db/fixtures/` incrementally

### Implementation Details

#### Principle: Use Service Classes in Seed Files

In seed files, **avoid using ActiveRecord subclasses directly; as a rule, use service classes under `app/services/`**.

Reasons:
1. **Data is loaded through the same process as production**: By going through service classes, data is loaded with the same logic as production -- including validations, callbacks, and related data creation
2. **Prevention of data inconsistency**: Implementing idempotency guarantees in service classes ensures safety when re-running seeds
3. **Testability**: Service classes are easy to unit test

```ruby
# Recommended: Use a service class
result = AdminArea::Contents::SaveEntryService.new(
  content_type: content_type,
  content_entry: nil,
  fields_params: { 'title' => 'Sample Article' },
).call

# Not recommended: Use ActiveRecord directly
ContentEntry.create!(title: 'Sample Article', ...)
```

However, direct use of ActiveRecord is acceptable in the following cases:
- Loading simple master data (e.g., `Country.seed(:code, ...)`)
- Pure master data models where no service class exists
- Data that has no complex business logic

#### Basic Usage

```ruby
# db/fixtures/01_countries.rb
Country.seed(:code,
  { code: 'JP', name: 'Japan' },
  { code: 'US', name: 'United States' },
)
```

#### Execution Commands

```bash
# Run fixtures shared across all environments + current environment
rails db:seed_fu

# Specify a particular path
rails db:seed_fu FIXTURE_PATH=db/fixtures/_shared
```

## Impact

### Positive

- Enables idempotent management of seed data
- Easy separation of data by environment
- Per-tenant data management becomes well-organized

### Negative

- A transitional period of coexistence with the standard Rails `db/seeds.rb` will occur
- Migration of existing data is required

## Related

### History of seed-fu Development

seed-fu was [developed by Mobomo in 2008](https://www.mobomo.com/2008/04/seed-fu-simple-seed-data-for-rails/).

The `db/fixtures/` naming convention was inherited from the `db-populate` plugin that seed-fu was inspired by. Since Rails' `db/seeds.rb` was added in Rails 2.3.4 (2009), seed-fu/db-populate predates it.

In other words, the reason seed-fu uses `db/fixtures` rather than `db/seeds` is the historical fact that it existed before Rails' seeds feature.

### Related Links

- [GitHub - mbleigh/seed-fu](https://github.com/mbleigh/seed-fu)
- [Seed Fu: Simple Seed Data for Rails (2008)](https://www.mobomo.com/2008/04/seed-fu-simple-seed-data-for-rails/)

---

*Note: This ADR was written on 2025/12/29, but the decision itself was made on 2025/11/19, so the date has been backdated accordingly.*
