# SQL Rules

## Principle: Raw SQL is prohibited

Use ActiveRecord features (`joins`, `where`, `includes`, etc.) instead.

## When raw SQL is unavoidable

1. **Document the reason**: Explain why AR cannot handle the case
2. **Get user approval**: Confirm with the user before implementation

## Example

```ruby
# Bad: Raw SQL
.joins(<<~SQL)
  INNER JOIN foo ON foo.id = bar.foo_id
SQL

# Good: AR joins
.joins(bar: :foo)
```
