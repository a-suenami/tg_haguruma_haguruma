import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-form-field-heading',
  imports: [CommonModule],
  templateUrl: './form-field-heading.component.html',
  styleUrl: './form-field-heading.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FormFieldHeadingComponent {}
