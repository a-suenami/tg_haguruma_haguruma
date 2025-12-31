import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-fab-button-text',
  imports: [CommonModule],
  template: '<ng-content></ng-content>',
  styleUrl: './fab-button-text.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    class: 'cog-fab-button-text',
  },
})
export class FabButtonText {}
