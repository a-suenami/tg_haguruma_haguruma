import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-form-field-control',
  imports: [CommonModule],
  templateUrl: './form-field-control.component.html',
  styleUrl: './form-field-control.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FormFieldControlComponent {}
