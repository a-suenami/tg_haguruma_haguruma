import type { Meta, StoryObj } from '@storybook/angular';

import { FilledCircleExclamationMarkIcon } from './icon-filled-circle-exclamation-mark.icon';

const meta: Meta<FilledCircleExclamationMarkIcon> = {
  title: 'Core/Components/Icons/FilledCircleExclamationMarkIcon',
  component: FilledCircleExclamationMarkIcon,
  tags: ['autodocs'],
};

export default meta;

type Story = StoryObj<FilledCircleExclamationMarkIcon>;

export const Default: Story = {
  render: (args) => ({
    props: args,
    template: `<cog-icon-filled-circle-exclamation-mark />`,
  }),
};
