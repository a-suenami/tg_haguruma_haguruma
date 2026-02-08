# ADR: Introduction of the UserArea alpha Namespace

- **Date**: 2025-12-25
- **Status**: Decided

## Context

There is a requirement to implement full-stack CMS screens in UserArea.

### Ideal Implementation

In the future, we want to build a dynamic page system that allows flexible screen creation by specifying:

- URL (path parameters specified with `:var` or `${var}`)
- Template (ERB or Liquid)
- Content type to load
  - For singletons: content type only
  - For collections: filter conditions

### Short-Term Requirements

The specific screens needed are already determined, and we want to implement them as quickly as possible without waiting for the dynamic page system to be completed. However, the architecture must allow for easy transition to the final implementation in the future.

### Design Considerations

1. **URL stability**: URLs must not change when transitioning from the short-term implementation to the final implementation
2. **Code separation**: The short-term implementation (hardcoded) and the final implementation should be clearly separated
3. **Reuse of shared logic**: Authentication, tenant configuration, and other shared logic should be reused by inheriting from the existing `UserArea::ApplicationController`

## Decision

**Introduce an `alpha` namespace to isolate the short-term implementation.**

Specifically:

1. Create the `app/controllers/user_area/alpha/` directory
2. Create `UserArea::Alpha::BaseController`, inheriting from `UserArea::ApplicationController`
3. Use `scope module: :alpha` in routing so that only the controller is swapped without affecting the URL path

### Why alpha Instead of v2

- The ideal form (dynamic page system) is the "canonical" implementation
- The short-term hardcoded implementation is "provisional" and should be treated as such
- `v2` implies "new version" and should be placed on the canonical path
- `alpha` means "initial/experimental" and clearly conveys the intent that it will be removed later

## Rationale

### Directory Structure

```
app/controllers/user_area/
├── application_controller.rb        # Shared (authentication, tenant config)
├── contents_controller.rb           # Existing
├── alpha/                            # Short-term implementation
│   ├── base_controller.rb           # < ApplicationController
│   └── pages_controller.rb          # Actions for each screen
```

### Routing

```ruby
# config/routes/user_area.rb
namespace :user_area, path: '' do
  # Existing routes...

  # alpha: short-term implementation (to be removed after dynamic page system is complete)
  scope module: :alpha do
    get '/products', to: 'pages#products'
    # Other screens...
  end
end
```

`scope module: :alpha` does not affect the URL path:

| Syntax | URL | Controller |
|--------|-----|------------|
| `scope module: :alpha` | `/products` | `UserArea::Alpha::PagesController` |
| `namespace :alpha` | `/alpha/products` | `UserArea::Alpha::PagesController` |

### Migration to the Final Implementation

After the dynamic page system is complete:

```ruby
# Before (alpha)
scope module: :alpha do
  get '/products', to: 'pages#products'
end

# After (final implementation)
get '*path', to: 'pages#show', constraints: UserArea::PageConstraint
```

The URL remains unchanged; only the controller is swapped. The `alpha/` directory can then be deleted.

## Impact

### Positive

- Clear boundary between the short-term and final implementations
- URLs remain stable and require no changes during the transition
- Shared logic such as authentication and tenant configuration is reused via inheritance
- Migration is completed simply by deleting the `alpha/` directory

### Negative

- During the short-term implementation period, `alpha/` code and future final implementation code may coexist
- If the `alpha` naming persists too long, its intent becomes ambiguous; it should be promptly removed after the final implementation is complete
