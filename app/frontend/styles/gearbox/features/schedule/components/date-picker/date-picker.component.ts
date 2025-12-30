import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  model,
  ViewChild,
} from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';
import { provideNativeDateAdapter } from '@angular/material/core';
import {
  MatDatepicker,
  MatDatepickerModule,
  MatDatepickerInputEvent,
} from '@angular/material/datepicker';
import { MatFormField, MatInput } from '@angular/material/input';

import { BackArrowIcon, ForwardArrowIcon, TriangleIcon } from '@gearbox/ui';

import dayjs from '../../../../utils/dayjs';

export interface DatePickerConfig {
  minDate?: Date;
  maxDate?: Date;
  disabledDates?: Date[];
  weekStartsOn?: 0 | 1 | 2 | 3 | 4 | 5 | 6;
  locale?: string;
  format?: string;
}

@Component({
  selector: 'cog-date-picker',
  providers: [provideNativeDateAdapter()],
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatInput,
    MatFormField,
    MatDatepickerModule,
    BackArrowIcon,
    ForwardArrowIcon,
    TriangleIcon,
  ],
  templateUrl: './date-picker.component.html',
  styleUrl: './date-picker.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DatePickerComponent {
  @ViewChild('picker') datepicker!: MatDatepicker<Date>;

  selectedDate = model<Date>(new Date());

  onDateChange(event: MatDatepickerInputEvent<Date>): void {
    if (event.value) {
      this.selectedDate.set(event.value);
    }
  }

  previousMonth(): void {
    const newDate = dayjs(this.selectedDate())
      .subtract(1, 'month')
      .toDate();
    this.selectedDate.set(newDate);
  }

  nextMonth(): void {
    const newDate = dayjs(this.selectedDate()).add(1, 'month').toDate();
    this.selectedDate.set(newDate);
  }
}
