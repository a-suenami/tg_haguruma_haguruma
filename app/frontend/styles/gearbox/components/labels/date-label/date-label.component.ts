import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-date-label',
  imports: [CommonModule],
  template: ` <ng-content></ng-content> `,
  styleUrl: './date-label.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DateLabel {}
