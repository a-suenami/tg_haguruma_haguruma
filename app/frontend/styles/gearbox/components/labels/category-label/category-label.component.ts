import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-category-label',
  imports: [CommonModule],
  template: ` <ng-content></ng-content> `,
  styleUrl: './category-label.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CategoryLabel {}
