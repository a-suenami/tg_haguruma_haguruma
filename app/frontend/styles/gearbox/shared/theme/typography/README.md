# Typography CSS Variables

## Font Family

- `--gearbox-font-family-heading`: "Tsukimi Rounded", sans-serif
- `--gearbox-font-family-primary`: "Zen Maru Gothic", sans-serif
- `--gearbox-font-family-system`: "Hiragino Sans", sans-serif

## Font Weight

- `--gearbox-font-weight-light`: 300
- `--gearbox-font-weight-regular`: 400
- `--gearbox-font-weight-medium`: 500
- `--gearbox-font-weight-semibold`: 600
- `--gearbox-font-weight-bold`: 700

## Line Height

- `--gearbox-line-height-solid`: 1
- `--gearbox-line-height-tight`: 1.2
- `--gearbox-line-height-normal`: 1.5
- `--gearbox-line-height-relaxed`: 1.6
- `--gearbox-line-height-loose`: 1.8

## Font Size

Font sizes are responsive and change based on screen size. Values shown are for mobile (SP) / desktop (PC).

### Heading Sizes

- `--gearbox-font-size-heading-large`: 2rem / 3rem (32px / 48px)
- `--gearbox-font-size-heading-medium`: 1.75rem / 2.5rem (28px / 40px)
- `--gearbox-font-size-heading-small`: 1.5rem / 2rem (24px / 32px)

### Title Sizes

- `--gearbox-font-size-title-large`: 1.375rem / 1.75rem (22px / 28px)
- `--gearbox-font-size-title-medium`: 1.25rem / 1.5rem (20px / 24px)
- `--gearbox-font-size-title-small`: 1.125rem / 1.25rem (18px / 20px)

### Body Sizes

- `--gearbox-font-size-body-large`: 1rem / 1.125rem (16px / 18px)
- `--gearbox-font-size-body-medium`: 0.9375rem / 1rem (15px / 16px)
- `--gearbox-font-size-body-small`: 0.875rem / 0.875rem (14px / 14px)

### Caption Sizes

- `--gearbox-font-size-caption-large`: 0.8125rem / 0.875rem (13px / 14px)
- `--gearbox-font-size-caption-medium`: 0.75rem / 0.75rem (12px / 12px)
- `--gearbox-font-size-caption-small`: 0.625rem / 0.625rem (10px / 10px)

## Usage Example

```scss
.heading {
  font-family: var(--gearbox-font-family-heading);
  font-size: var(--gearbox-font-size-heading-large);
  font-weight: var(--gearbox-font-weight-bold);
  line-height: var(--gearbox-line-height-tight);
}

.body-text {
  font-family: var(--gearbox-font-family-primary);
  font-size: var(--gearbox-font-size-body-medium);
  font-weight: var(--gearbox-font-weight-regular);
  line-height: var(--gearbox-line-height-normal);
}

.caption {
  font-family: var(--gearbox-font-family-system);
  font-size: var(--gearbox-font-size-caption-small);
  font-weight: var(--gearbox-font-weight-light);
  line-height: var(--gearbox-line-height-relaxed);
}
```
