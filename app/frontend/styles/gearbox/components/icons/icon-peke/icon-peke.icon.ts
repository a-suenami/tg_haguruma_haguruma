import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-icon-peke',
  imports: [CommonModule],
  templateUrl: '../svg-files/icon_peke.svg',
  styleUrls: ['../styles/cog-icon.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PekeIcon {}

