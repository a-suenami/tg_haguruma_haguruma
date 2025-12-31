import type { Meta, StoryObj } from '@storybook/angular';
import { moduleMetadata } from '@storybook/angular';

import { ScheduleDetailPage } from './schedule-detail.page';

const meta: Meta<ScheduleDetailPage> = {
  title: 'Features/Schedule/Pages/ScheduleDetail',
  component: ScheduleDetailPage,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [ScheduleDetailPage],
    }),
  ],
  parameters: {
    layout: 'fullscreen',
  },
};

export default meta;
type Story = StoryObj<ScheduleDetailPage>;

export const Default: Story = {
  render: () => ({
    template: `<cog-schedule-detail></cog-schedule-detail>`,
  }),
};
