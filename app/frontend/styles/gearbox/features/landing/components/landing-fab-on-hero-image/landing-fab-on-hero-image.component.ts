import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-landing-fab-on-hero-image',
  imports: [CommonModule],
  templateUrl: './landing-fab-on-hero-image.component.html',
  styleUrl: './landing-fab-on-hero-image.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LandingFabOnHeroImageComponent {}
