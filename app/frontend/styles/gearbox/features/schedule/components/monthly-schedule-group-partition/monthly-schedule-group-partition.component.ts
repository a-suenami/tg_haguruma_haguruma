import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
  selector: 'cog-monthly-schedule-group-partition',
  imports: [CommonModule],
  templateUrl: './monthly-schedule-group-partition.component.html',
  styleUrl: './monthly-schedule-group-partition.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class MonthlyScheduleGroupPartitionComponent {
  month = input<string>('07');
  year = input<string>('2025');
}
