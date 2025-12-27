import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-icon-forward-arrow',
  imports: [CommonModule],
  templateUrl: '../svg-files/icon_forward-arrow.svg',
  styleUrls: ['../styles/cog-icon.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ForwardArrowIcon {}
