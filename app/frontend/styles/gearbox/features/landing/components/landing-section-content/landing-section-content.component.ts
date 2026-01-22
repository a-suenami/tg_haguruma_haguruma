import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-landing-section-content',
  imports: [CommonModule],
  template: `<ng-content></ng-content>`,
  styleUrl: './landing-section-content.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LandingSectionContentComponent {}
