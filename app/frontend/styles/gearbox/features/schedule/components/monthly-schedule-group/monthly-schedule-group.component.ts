import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-monthly-schedule-group',
  imports: [CommonModule],
  templateUrl: './monthly-schedule-group.component.html',
  styleUrl: './monthly-schedule-group.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class MonthlyScheduleGroupComponent {}
