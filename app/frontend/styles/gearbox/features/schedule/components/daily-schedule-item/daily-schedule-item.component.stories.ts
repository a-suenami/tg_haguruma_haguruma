import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { DummyScheduleItem } from '../monthly-schedule-list/dummy-schedule-items';
import { DailyScheduleItemComponent } from './daily-schedule-item.component';

const meta: Meta<DailyScheduleItemComponent> = {
  title: 'Features/Schedule/Components/DailyScheduleItem',
  component: DailyScheduleItemComponent,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [DailyScheduleItemComponent],
    }),
  ],
  parameters: {
    layout: 'padded',
  },
};

export default meta;
type Story = StoryObj<DailyScheduleItemComponent>;

export const Default: Story = {
  render: () => {
    const scheduleItem: DummyScheduleItem = {
      date: '2025-07-01',
      category: 'LIVE',
      title: 'CANDY CARNIVAL TOUR 2025 - 東京ドーム',
    };

    return {
      props: { scheduleItem },
      template: `
        <cog-daily-schedule-item [schedule]="scheduleItem"></cog-daily-schedule-item>
      `,
    };
  },
};
