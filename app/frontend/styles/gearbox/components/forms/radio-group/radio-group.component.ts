import { CommonModule } from '@angular/common';
import {
  booleanAttribute,
  ChangeDetectionStrategy,
  Component,
  contentChildren,
  effect,
  forwardRef,
  InjectionToken,
  input,
  model,
  OnInit,
  output,
} from '@angular/core';

import { RadioComponent } from '../radio/radio.component';

export const COG_RADIO_GROUP = new InjectionToken<RadioGroupComponent>(
  'COG_RADIO_GROUP',
);

@Component({
  selector: 'cog-radio-group',
  imports: [CommonModule],
  templateUrl: './radio-group.component.html',
  styleUrl: './radio-group.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [
    {
      provide: COG_RADIO_GROUP,
      useExisting: RadioGroupComponent,
    },
  ],
})
export class RadioGroupComponent implements OnInit {
  readonly defaultValue = input<string | null>(null);
  readonly disabled = input(false, { transform: booleanAttribute });

  readonly value = model<string | null>(null);
  readonly changed = output<string | null>();

  private readonly radioQuery = contentChildren(
    forwardRef(() => RadioComponent),
    { descendants: true },
  );

  constructor() {
    effect(() => {
      const radios: ReadonlyArray<RadioComponent> = this.radioQuery();

      const currentValue = this.value();
      if (
        currentValue !== null &&
        !radios.some((radio) => radio.value() === currentValue)
      ) {
        this.selectValue(null, false);
      }
    });
  }

  ngOnInit(): void {
    const defaultValue = this.defaultValue();
    if (defaultValue !== null) {
      this.selectValue(defaultValue, false);
    }
  }

  notifyChecked(radio: RadioComponent): void {
    this.selectValue(radio.value());
  }

  isSelected(value: string | null): boolean {
    return value !== null && this.value() === value;
  }

  private selectValue(value: string | null, emit = true): void {
    if (this.value() === value) {
      return;
    }
    this.value.set(value);
    if (emit) {
      this.changed.emit(value);
    }
  }
}
