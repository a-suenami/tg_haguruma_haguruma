import { ChangeDetectionStrategy, Component } from '@angular/core';

import { FilledCircleExclamationMarkIcon } from '../../icons/icon-filled-circle-exclamation-mark/icon-filled-circle-exclamation-mark.icon';

@Component({
  selector: 'cog-form-field-error',
  imports: [FilledCircleExclamationMarkIcon],
  templateUrl: './form-field-error.component.html',
  styleUrl: './form-field-error.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FormFieldErrorComponent {}
