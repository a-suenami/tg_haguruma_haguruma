import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-daily-schedule-items',
  imports: [CommonModule],
  templateUrl: './daily-schedule-items.component.html',
  styleUrl: './daily-schedule-items.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DailyScheduleItemsComponent {}
