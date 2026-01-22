import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, input } from '@angular/core';

import { CategoryLabel } from '@gearbox/ui';

import { DayjsFormatPipe } from '../../../../pipes/dayjs-format.pipe';
import { DummyScheduleItem } from '../monthly-schedule-list/dummy-schedule-items';

@Component({
  selector: 'cog-daily-schedule-item',
  imports: [CommonModule, CategoryLabel, DayjsFormatPipe],
  templateUrl: './daily-schedule-item.component.html',
  styleUrl: './daily-schedule-item.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DailyScheduleItemComponent {
  schedule = input.required<DummyScheduleItem>();
}
