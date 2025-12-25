import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  effect,
  model,
  output,
} from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { provideNativeDateAdapter } from '@angular/material/core';
import { MatDatepickerModule } from '@angular/material/datepicker';

@Component({
  selector: 'cog-inline-calendar',
  imports: [CommonModule, MatDatepickerModule, MatCardModule],
  providers: [provideNativeDateAdapter()],
  templateUrl: './inline-calendar.component.html',
  styleUrl: './inline-calendar.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class InlineCalendarComponent {
  selected = model<Date | null>(null);
  date = output<Date>();

  constructor() {
    effect(() => {
      const selected = this.selected();
      if (selected) {
        this.date.emit(selected);
      }
    });
  }
}
