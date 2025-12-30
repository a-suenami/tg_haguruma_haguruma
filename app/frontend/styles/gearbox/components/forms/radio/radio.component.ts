import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
  model,
  output,
} from '@angular/core';

import { COG_RADIO_GROUP } from '../radio-group/radio-group.component';

@Component({
  selector: 'cog-radio',
  imports: [CommonModule],
  templateUrl: './radio.component.html',
  styleUrl: './radio.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class RadioComponent {
  readonly id = input<string | null>(null);
  readonly name = input<string | null>(null);
  readonly value = input<string>('on');

  readonly checked = model(false);
  readonly changed = output<boolean>();

  private readonly fallbackId = `cog-radio-${crypto.randomUUID()}`;

  private readonly group = inject(COG_RADIO_GROUP, { optional: true });

  protected readonly resolvedId = computed(() => this.id() ?? this.fallbackId);

  protected readonly resolvedName = computed(
    () => this.name() ?? this.resolvedId(),
  );

  protected readonly isDisabled = computed(
    () => this.group?.disabled() ?? false,
  );

  protected readonly isChecked = computed(() => {
    if (this.group) {
      return this.group.isSelected(this.value());
    }

    return this.checked();
  });

  protected changeValue(event: Event): void {
    const target = event.target as HTMLInputElement | null;
    if (!target || this.isDisabled()) {
      return;
    }

    if (this.group) {
      if (target.checked) {
        this.group.notifyChecked(this);
      }
      return;
    }

    const nextChecked = target.checked;
    this.checked.set(nextChecked);
    this.changed.emit(nextChecked);
  }
}
