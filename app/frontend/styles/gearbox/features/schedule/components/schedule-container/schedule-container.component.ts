import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-schedule-container',
  imports: [CommonModule],
  templateUrl: './schedule-container.component.html',
  styleUrls: [
    './schedule-container.component.scss',
    './styles/schedule-container.browser.scss',
    './styles/schedule-container.tablet.scss',
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ScheduleContainerComponent {}
