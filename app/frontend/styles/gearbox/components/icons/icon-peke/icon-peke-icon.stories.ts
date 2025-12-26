import type { Meta, StoryObj } from '@storybook/angular';

import { PekeIcon } from './icon-peke.icon';

const meta: Meta<PekeIcon> = {
  title: 'Core/Components/Icons/PekeIcon',
  component: PekeIcon,
  tags: ['autodocs'],
};

export default meta;

type Story = StoryObj<PekeIcon>;

export const Default: Story = {
  render: (args) => ({
    props: args,
    template: `<cog-icon-peke />`,
  }),
};
