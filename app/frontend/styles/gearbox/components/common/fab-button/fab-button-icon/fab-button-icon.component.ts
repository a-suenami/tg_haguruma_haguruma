import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-fab-button-icon',
  imports: [CommonModule],
  template: '<ng-content></ng-content>',
  styleUrl: './fab-button-icon.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    class: 'cog-fab-button-icon',
  },
})
export class FabButtonIcon {}
