import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-landing-section-title',
  imports: [CommonModule],
  template: `<ng-content></ng-content>`,
  styleUrl: './landing-section-title.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LandingSectionTitleComponent {}
