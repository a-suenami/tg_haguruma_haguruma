import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

import { CheckIcon } from '../icon-check/check.icon';

@Component({
  selector: 'cog-icon-back-arrow',
  imports: [CommonModule, CheckIcon],
  templateUrl: '../svg-files/icon_back-arrow.svg',
  styleUrls: ['../styles/cog-icon.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BackArrowIcon {}
