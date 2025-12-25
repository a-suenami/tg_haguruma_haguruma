import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-form-field-error-slot',
  imports: [CommonModule],
  templateUrl: './form-field-error-slot.component.html',
  styleUrl: './form-field-error-slot.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FormFieldErrorSlotComponent {}
