import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'select[cog-select]',

  template: '<ng-content></ng-content>',
  styleUrl: './select.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SelectComponent {}
