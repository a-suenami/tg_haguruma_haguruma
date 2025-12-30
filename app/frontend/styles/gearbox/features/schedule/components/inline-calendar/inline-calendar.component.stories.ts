import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { InlineCalendarComponent } from './inline-calendar.component';

const meta: Meta<InlineCalendarComponent> = {
  title: 'Features/Schedule/Components/InlineCalendar',
  component: InlineCalendarComponent,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [InlineCalendarComponent],
    }),
  ],
  parameters: {
    layout: 'centered',
  },
};

export default meta;
type Story = StoryObj<InlineCalendarComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="width: 400px; padding: 2rem; background-color: var(--gearbox-background);">
        <cog-inline-calendar></cog-inline-calendar>
      </div>
    `,
  }),
};
