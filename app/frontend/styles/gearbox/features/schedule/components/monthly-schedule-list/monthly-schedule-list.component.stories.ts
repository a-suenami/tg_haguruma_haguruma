import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { MonthlyScheduleListComponent } from './monthly-schedule-list.component';

const meta: Meta<MonthlyScheduleListComponent> = {
  title: 'Features/Schedule/Components/MonthlyScheduleList',
  component: MonthlyScheduleListComponent,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [MonthlyScheduleListComponent],
    }),
  ],
  parameters: {
    layout: 'padded',
  },
};

export default meta;
type Story = StoryObj<MonthlyScheduleListComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="max-width: 1200px; margin: 0 auto;">
        <cog-monthly-schedule-list>
        </cog-monthly-schedule-list>
      </div>
    `,
  }),
};
