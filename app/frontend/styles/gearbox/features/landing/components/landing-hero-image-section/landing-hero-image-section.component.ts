import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-landing-hero-image-section',
  imports: [CommonModule],
  templateUrl: './landing-hero-image-section.component.html',
  styleUrl: './landing-hero-image-section.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LandingHeroImageSectionComponent {}
