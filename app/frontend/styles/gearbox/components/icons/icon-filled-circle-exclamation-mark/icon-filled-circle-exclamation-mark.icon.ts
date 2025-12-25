import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-icon-filled-circle-exclamation-mark',
  imports: [CommonModule],
  templateUrl: '../svg-files/icon_filled-circle-exclamation-mark.svg',
  styleUrls: ['../styles/cog-icon.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FilledCircleExclamationMarkIcon {}

