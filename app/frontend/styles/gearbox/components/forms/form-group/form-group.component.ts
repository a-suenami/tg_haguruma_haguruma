import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-form-group',
  imports: [CommonModule],
  templateUrl: './form-group.component.html',
  styleUrl: './form-group.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FormGroupComponent {}
