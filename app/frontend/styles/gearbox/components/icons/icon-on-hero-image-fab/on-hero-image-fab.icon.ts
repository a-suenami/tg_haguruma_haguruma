import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-icon-on-hero-image-fab',
  imports: [CommonModule],
  templateUrl: '../svg-files/icon_on-hero-image-fab.svg',
  styleUrls: ['../styles/cog-icon.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class OnHeroImageFabIcon {}
