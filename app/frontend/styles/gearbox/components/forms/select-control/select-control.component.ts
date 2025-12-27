import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

import { DownTriangleIcon } from '../../icons/icon-down-triangle/down-triangle.icon';

@Component({
  selector: 'cog-select-control',
  imports: [CommonModule, DownTriangleIcon],
  templateUrl: './select-control.component.html',
  styleUrl: './select-control.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SelectControlComponent {}
