import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
  selector: 'a[cog-landing-banner]',
  imports: [CommonModule],
  templateUrl: './landing-banner.component.html',
  styleUrl: './landing-banner.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LandingBannerComponent {
  src = input.required<string>();
  alt = input.required<string>();
}
