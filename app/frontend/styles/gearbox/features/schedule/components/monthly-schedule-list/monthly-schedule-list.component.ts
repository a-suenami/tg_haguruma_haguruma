import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  signal,
} from '@angular/core';
import { RouterLink } from '@angular/router';

import dayjs from '../../../../utils/dayjs';
import { DailyScheduleItemComponent } from '../daily-schedule-item/daily-schedule-item.component';
import { DailyScheduleItemsComponent } from '../daily-schedule-items/daily-schedule-items.component';
import { MonthlyScheduleGroupPartitionComponent } from '../monthly-schedule-group-partition/monthly-schedule-group-partition.component';
import { MonthlyScheduleGroupComponent } from '../monthly-schedule-group/monthly-schedule-group.component';
import { DummyScheduleItem, dummyScheduleItems } from './dummy-schedule-items';

@Component({
  selector: 'cog-monthly-schedule-list',
  imports: [
    CommonModule,
    MonthlyScheduleGroupComponent,
    MonthlyScheduleGroupPartitionComponent,
    DailyScheduleItemsComponent,
    DailyScheduleItemComponent,
    RouterLink,
  ],
  templateUrl: './monthly-schedule-list.component.html',
  styleUrl: './monthly-schedule-list.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    '[class.is-scrolling]': 'true',
  },
})
export class MonthlyScheduleListComponent {
  scheduleItems = signal<DummyScheduleItem[]>(dummyScheduleItems);

  // Group schedule items by month
  groupedSchedules = computed(() => {
    const items = this.scheduleItems();
    const grouped = new Map<string, DummyScheduleItem[]>();

    items.forEach((item) => {
      const monthKey = dayjs(item.date).format('YYYY-MM');
      if (!grouped.has(monthKey)) {
        grouped.set(monthKey, []);
      }
      grouped.get(monthKey)?.push(item);
    });

    // Convert to array and sort by month
    return Array.from(grouped.entries())
      .sort((a, b) => a[0].localeCompare(b[0]))
      .map(([monthKey, items]) => ({
        monthKey,
        month: dayjs(monthKey + '-01').format('MM'),
        year: dayjs(monthKey + '-01').format('YYYY'),
        items: items.sort((a, b) => a.date.localeCompare(b.date)),
      }));
  });
}
