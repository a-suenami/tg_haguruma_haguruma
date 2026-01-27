---
name: tapioca
description: Tapioca checklist for Sorbet type generation. Apply when modifying gems, models, routes, or DB schemas.
user-invocable: false
---

# Tapioca Checklist

This project uses Sorbet + Tapioca. Run the appropriate tapioca command after making the following changes.

## When to Run

### Run `tapioca gem`

After adding a new gem (after modifying Gemfile and running bundle install):

```bash
source env.sh && bundle exec tapioca gem
```

### Run `tapioca dsl`

After modifying any of the following:

- **Models**: Files under `app/models/`
- **Routes**: Files under `config/routes/`
- **DB Schemas**: Files under `db/schemas/`

```bash
source env.sh && bundle exec tapioca dsl
```

To regenerate for a specific model only:

```bash
source env.sh && bundle exec tapioca dsl ModelName
```

## Pre-commit Checklist

1. Verify type check passes with `bundle exec srb tc .`
2. Include any newly generated RBI files in your commit:
   - `sorbet/rbi/gems/` - Gem RBI files
   - `sorbet/rbi/dsl/` - DSL RBI files
