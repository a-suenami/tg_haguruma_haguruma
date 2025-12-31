import { CommonModule } from '@angular/common';
import {
  booleanAttribute,
  ChangeDetectionStrategy,
  Component,
  input,
} from '@angular/core';

import { CheckIcon } from '../../icons/icon-check/check.icon';
import { PekeIcon } from '../../icons/icon-peke/icon-peke.icon';

@Component({
  selector: 'cog-form-field-requirement',
  imports: [CommonModule, PekeIcon, CheckIcon],
  templateUrl: './form-field-requirement.component.html',
  styleUrl: './form-field-requirement.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    '[class.valid]': 'valid()',
    '[class.invalid]': '!valid()',
    '[class.dirty]': 'dirty()',
  },
})
export class FormFieldRequirementComponent {
  valid = input(false, { transform: booleanAttribute });
  dirty = input(false, { transform: booleanAttribute });
}
