import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { ScheduleContainerComponent } from './schedule-container.component';

const meta: Meta<ScheduleContainerComponent> = {
  title: 'Features/Schedule/Components/ScheduleContainer',
  component: ScheduleContainerComponent,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [ScheduleContainerComponent],
    }),
  ],
  parameters: {
    layout: 'padded',
  },
};

export default meta;
type Story = StoryObj<ScheduleContainerComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="max-width: 1200px; margin: 0 auto;">
        <cog-schedule-container></cog-schedule-container>
      </div>
    `,
  }),
};
