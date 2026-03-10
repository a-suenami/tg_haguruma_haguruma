import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-icon-down-triangle',
  imports: [CommonModule],
  templateUrl: '../svg-files/icon_down-triangle.svg',
  styleUrls: ['../styles/cog-icon.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DownTriangleIcon {}
