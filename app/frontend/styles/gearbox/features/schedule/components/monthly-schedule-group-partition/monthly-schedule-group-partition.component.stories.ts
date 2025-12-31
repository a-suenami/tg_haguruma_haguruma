import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { MonthlyScheduleGroupPartitionComponent } from './monthly-schedule-group-partition.component';

const meta: Meta<MonthlyScheduleGroupPartitionComponent> = {
  title: 'Features/Schedule/Components/MonthlyScheduleGroupPartition',
  component: MonthlyScheduleGroupPartitionComponent,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [MonthlyScheduleGroupPartitionComponent],
    }),
  ],
  parameters: {
    layout: 'padded',
  },
};

export default meta;
type Story = StoryObj<MonthlyScheduleGroupPartitionComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="max-width: 600px; margin: 0 auto;">
        <cog-monthly-schedule-group-partition></cog-monthly-schedule-group-partition>
      </div>
    `,
  }),
};
