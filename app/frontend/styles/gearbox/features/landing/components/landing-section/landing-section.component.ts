import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-landing-section',
  imports: [CommonModule],
  templateUrl: './landing-section.component.html',
  styleUrl: './landing-section.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LandingSectionComponent {}
