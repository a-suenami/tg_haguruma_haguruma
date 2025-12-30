import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-form-field-label',
  imports: [CommonModule],
  templateUrl: './form-field-label.component.html',
  styleUrl: './form-field-label.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FormFieldLabelComponent {}
