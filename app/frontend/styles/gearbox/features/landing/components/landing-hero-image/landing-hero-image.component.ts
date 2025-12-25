import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-landing-hero-image',
  imports: [CommonModule],
  templateUrl: './landing-hero-image.component.html',
  styleUrl: './landing-hero-image.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LandingHeroImageComponent {}
