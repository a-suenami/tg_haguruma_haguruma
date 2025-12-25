import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { DailyScheduleItemComponent } from '../daily-schedule-item/daily-schedule-item.component';
import { DailyScheduleItemsComponent } from '../daily-schedule-items/daily-schedule-items.component';
import { MonthlyScheduleGroupPartitionComponent } from '../monthly-schedule-group-partition/monthly-schedule-group-partition.component';
import { MonthlyScheduleGroupComponent } from './monthly-schedule-group.component';

const meta: Meta<MonthlyScheduleGroupComponent> = {
  title: 'Features/Schedule/Components/MonthlyScheduleGroup',
  component: MonthlyScheduleGroupComponent,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [
        MonthlyScheduleGroupComponent,
        DailyScheduleItemComponent,
        DailyScheduleItemsComponent,
        MonthlyScheduleGroupPartitionComponent,
      ],
    }),
  ],
  parameters: {
    layout: 'padded',
  },
};

export default meta;
type Story = StoryObj<MonthlyScheduleGroupComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="max-width: 800px; margin: 0 auto;">
        <cog-monthly-schedule-group>
          <cog-monthly-schedule-group-partition></cog-monthly-schedule-group-partition>
          <cog-daily-schedule-items>
            <cog-daily-schedule-item></cog-daily-schedule-item>
            <cog-daily-schedule-item></cog-daily-schedule-item>
            <cog-daily-schedule-item></cog-daily-schedule-item>
          </cog-daily-schedule-items>
        </cog-monthly-schedule-group>
      </div>
    `,
  }),
};
