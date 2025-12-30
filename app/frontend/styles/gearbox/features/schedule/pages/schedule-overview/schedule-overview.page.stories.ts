import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { ScheduleOverviewPage } from './schedule-overview.page';

const meta: Meta<ScheduleOverviewPage> = {
  title: 'Features/Schedule/Pages/ScheduleOverview',
  component: ScheduleOverviewPage,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [ScheduleOverviewPage],
    }),
  ],
  parameters: {
    layout: 'fullscreen',
  },
};

export default meta;
type Story = StoryObj<ScheduleOverviewPage>;

export const Default: Story = {
  render: () => ({
    template: `<cog-schedule-overview></cog-schedule-overview>`,
  }),
};
