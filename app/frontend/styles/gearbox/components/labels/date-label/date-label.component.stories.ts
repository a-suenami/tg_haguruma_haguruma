import type { Meta, StoryObj } from '@storybook/angular';

import { DateLabel } from './date-label.component';

const meta: Meta<DateLabel> = {
  component: DateLabel,
  title: 'Core/Components/Labels/DateLabel',
  render: (args) => ({
    props: args,
    template: `
      <cog-date-label>2024.12.25</cog-date-label>
    `,
  }),
};
export default meta;

type Story = StoryObj<DateLabel>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; display: flex; gap: 2rem; flex-wrap: wrap;">
        <cog-date-label>2024.12.25</cog-date-label>
      </div>
    `,
  }),
};
