import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-landing-section-actions',
  imports: [CommonModule],
  templateUrl: './landing-section-actions.component.html',
  styleUrl: './landing-section-actions.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LandingSectionActionsComponent {}
