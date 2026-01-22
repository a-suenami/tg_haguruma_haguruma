# Spacing System

## CSS Variables

The spacing system provides consistent spacing values throughout the application using CSS custom properties.

### Available Variables

| Variable                 | Value    | Pixels |
| ------------------------ | -------- | ------ |
| `--gearbox-spacing-unit` | 0.25rem  | 4px    |
| `--gearbox-spacing-0`    | 0        | 0px    |
| `--gearbox-spacing-2`    | 0.125rem | 2px    |
| `--gearbox-spacing-4`    | 0.25rem  | 4px    |
| `--gearbox-spacing-6`    | 0.375rem | 6px    |
| `--gearbox-spacing-8`    | 0.5rem   | 8px    |
| `--gearbox-spacing-12`   | 0.75rem  | 12px   |
| `--gearbox-spacing-16`   | 1rem     | 16px   |
| `--gearbox-spacing-20`   | 1.25rem  | 20px   |
| `--gearbox-spacing-24`   | 1.5rem   | 24px   |
| `--gearbox-spacing-32`   | 2rem     | 32px   |
| `--gearbox-spacing-40`   | 2.5rem   | 40px   |
| `--gearbox-spacing-48`   | 3rem     | 48px   |
| `--gearbox-spacing-64`   | 4rem     | 64px   |
| `--gearbox-spacing-80`   | 5rem     | 80px   |
| `--gearbox-spacing-96`   | 6rem     | 96px   |

## Usage

```css
.example {
  padding: var(--gearbox-spacing-16);
  margin-bottom: var(--gearbox-spacing-24);
}
```
