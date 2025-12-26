import { CommonModule } from '@angular/common';
import {
  booleanAttribute,
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
  model,
  OnInit,
  output,
} from '@angular/core';

import { CheckIcon } from '../../icons/icon-check/check.icon';

@Component({
  selector: 'cog-checkbox',
  imports: [CommonModule, CheckIcon],
  templateUrl: './checkbox.component.html',
  styleUrl: './checkbox.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CheckboxComponent implements OnInit {
  readonly id = input<string | null>(null);
  readonly name = input<string | null>(null);
  readonly value = input<string | null>('on');
  readonly checked = input(false, { transform: booleanAttribute });
  readonly disabled = input(false, { transform: booleanAttribute });

  readonly isChecked = model(false);
  readonly changed = output<boolean>();

  private readonly fallbackId = `cog-checkbox-${crypto.randomUUID()}`;

  protected readonly resolvedId = computed(() => this.id() ?? this.fallbackId);
  protected readonly resolvedName = computed(
    () => this.name() ?? this.resolvedId(),
  );

  ngOnInit() {
    this.isChecked.set(this.checked());
  }

  protected changeValue(event: Event): void {
    const target = event.target as HTMLInputElement | null;
    if (!target) {
      return;
    }

    const nextChecked = target.checked;
    this.isChecked.set(nextChecked);
    this.changed.emit(nextChecked);
  }
}
