import { signal } from '@angular/core';
import type { Meta, StoryObj } from '@storybook/angular';

import { DatePickerComponent } from './date-picker.component';

const meta: Meta<DatePickerComponent> = {
  title: 'Features/Schedule/Components/DatePicker',
  component: DatePickerComponent,
  tags: ['autodocs'],
  parameters: {
    docs: {
      description: {
        component:
          'Date picker component with Angular Material integration, custom triggers, and navigation arrows.',
      },
    },
  },
};

export default meta;
type Story = StoryObj<DatePickerComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background: var(--gearbox-background); min-height: 400px;">
        <cog-date-picker></cog-date-picker>
      </div>
    `,
  }),
};

export const WithSelectedDate: Story = {
  render: () => {
    const selectedDate = signal(new Date());
    return {
      props: { selectedDate },
      template: `
        <div style="padding: 2rem; background: var(--gearbox-background); min-height: 400px;">
          <cog-date-picker [(selectedDate)]="selectedDate"></cog-date-picker>
          <p style="margin-top: 1rem;">Selected: {{ selectedDate() | date:'yyyy/MM/dd' }}</p>
        </div>
      `,
    };
  },
};

export const WithMinMaxDates: Story = {
  render: () => {
    const today = new Date();
    const minDate = new Date(today);
    minDate.setDate(today.getDate() - 7);
    const maxDate = new Date(today);
    maxDate.setDate(today.getDate() + 7);

    const config = {
      minDate,
      maxDate,
      format: 'YYYY年MM月DD日',
    };

    return {
      props: { config },
      template: `
        <div style="padding: 2rem; background: var(--gearbox-background); min-height: 400px;">
          <cog-date-picker [config]="config"></cog-date-picker>
          <p style="margin-top: 1rem; font-size: 12px;">
            選択可能期間: 過去7日 〜 未来7日
          </p>
        </div>
      `,
    };
  },
};

export const WithDisabledDates: Story = {
  render: () => {
    const today = new Date();
    const disabledDates = [
      new Date(today.getFullYear(), today.getMonth(), 15),
      new Date(today.getFullYear(), today.getMonth(), 20),
      new Date(today.getFullYear(), today.getMonth(), 25),
    ];

    const config = {
      disabledDates,
      format: 'MM/DD/YYYY',
    };

    return {
      props: { config },
      template: `
        <div style="padding: 2rem; background: var(--gearbox-background); min-height: 400px;">
          <cog-date-picker [config]="config"></cog-date-picker>
          <p style="margin-top: 1rem; font-size: 12px;">
            15日、20日、25日は選択不可
          </p>
        </div>
      `,
    };
  },
};

export const MondayStart: Story = {
  render: () => {
    const config = {
      weekStartsOn: 1 as const,
      locale: 'en',
      format: 'DD/MM/YYYY',
    };

    return {
      props: { config },
      template: `
        <div style="padding: 2rem; background: var(--gearbox-background); min-height: 400px;">
          <cog-date-picker [config]="config"></cog-date-picker>
          <p style="margin-top: 1rem; font-size: 12px;">
            週の開始: 月曜日
          </p>
        </div>
      `,
    };
  },
};

export const TwoWayBinding: Story = {
  render: () => {
    // This demonstrates two-way binding with model
    const date1 = signal<Date | null>(new Date());
    const date2 = signal<Date | null>(null);

    return {
      props: { date1, date2 },
      template: `
        <div style="padding: 2rem; background: var(--gearbox-background); min-height: 400px;">
          <div style="display: flex; gap: 2rem;">
            <div>
              <h4>Picker 1</h4>
              <cog-date-picker [(selectedDate)]="date1"></cog-date-picker>
            </div>
            <div>
              <h4>Picker 2 (synced)</h4>
              <cog-date-picker [(selectedDate)]="date1"></cog-date-picker>
            </div>
          </div>
          <p style="margin-top: 1rem;">
            Both pickers share the same model: {{ date1() | date:'yyyy/MM/dd' }}
          </p>

          <hr style="margin: 2rem 0;" />

          <div>
            <h4>Independent Picker</h4>
            <cog-date-picker [(selectedDate)]="date2"></cog-date-picker>
            <p style="margin-top: 0.5rem;">
              Selected: {{ date2() ? (date2() | date:'yyyy/MM/dd') : 'None' }}
            </p>
          </div>
        </div>
      `,
    };
  },
};
