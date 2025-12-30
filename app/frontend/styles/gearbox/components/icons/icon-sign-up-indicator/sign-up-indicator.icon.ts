import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-icon-sign-up-indicator',
  imports: [CommonModule],
  templateUrl: '../svg-files/icon_sign-up-indicator.svg',
  styleUrls: ['../styles/cog-icon.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SignUpIndicatorIcon {}
