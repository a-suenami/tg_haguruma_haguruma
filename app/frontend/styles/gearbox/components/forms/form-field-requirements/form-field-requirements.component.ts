import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-form-field-requirements',
  imports: [CommonModule],
  templateUrl: './form-field-requirements.component.html',
  styleUrl: './form-field-requirements.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FormFieldRequirementsComponent {}
