import type { Meta, StoryObj } from '@storybook/angular';

import { SignUpIndicatorIcon } from './sign-up-indicator.icon';

const meta: Meta<SignUpIndicatorIcon> = {
  component: SignUpIndicatorIcon,
  title: 'Core/Components/Icons/SignUpIndicatorIcon',
  render: () => ({
    template: `<cog-icon-sign-up-indicator></cog-icon-sign-up-indicator>`,
  }),
};
export default meta;

type Story = StoryObj<SignUpIndicatorIcon>;

export const Default: Story = {};

export const CustomColor: Story = {
  render: () => ({
    template: `
      <div style="display: flex; gap: 10px; align-items: center;">
        <cog-icon-sign-up-indicator style="color: #1976D2;"></cog-icon-sign-up-indicator>
        <cog-icon-sign-up-indicator style="color: #DC004E;"></cog-icon-sign-up-indicator>
        <cog-icon-sign-up-indicator style="color: #388E3C;"></cog-icon-sign-up-indicator>
        <cog-icon-sign-up-indicator style="color: #F57C00;"></cog-icon-sign-up-indicator>
      </div>
    `,
  }),
};

export const DifferentSizes: Story = {
  render: () => ({
    template: `
      <div style="display: flex; gap: 10px; align-items: center;">
        <cog-icon-sign-up-indicator style="--cog-icon-size: 16px;"></cog-icon-sign-up-indicator>
        <cog-icon-sign-up-indicator style="--cog-icon-size: 24px;"></cog-icon-sign-up-indicator>
        <cog-icon-sign-up-indicator style="--cog-icon-size: 32px;"></cog-icon-sign-up-indicator>
        <cog-icon-sign-up-indicator style="--cog-icon-size: 48px;"></cog-icon-sign-up-indicator>
        <cog-icon-sign-up-indicator style="--cog-icon-size: 64px;"></cog-icon-sign-up-indicator>
      </div>
    `,
  }),
};
