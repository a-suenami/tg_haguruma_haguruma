import type { Meta, StoryObj } from '@storybook/angular';

import { SignInIndicatorIcon } from './sign-in-indicator.icon';

const meta: Meta<SignInIndicatorIcon> = {
  component: SignInIndicatorIcon,
  title: 'Core/Components/Icons/SignInIndicatorIcon',
  render: () => ({
    template: `<cog-icon-sign-in-indicator></cog-icon-sign-in-indicator>`,
  }),
};
export default meta;

type Story = StoryObj<SignInIndicatorIcon>;

export const Default: Story = {};

export const CustomColor: Story = {
  render: () => ({
    template: `
      <div style="display: flex; gap: 10px; align-items: center;">
        <cog-icon-sign-in-indicator style="color: #1976D2;"></cog-icon-sign-in-indicator>
        <cog-icon-sign-in-indicator style="color: #DC004E;"></cog-icon-sign-in-indicator>
        <cog-icon-sign-in-indicator style="color: #388E3C;"></cog-icon-sign-in-indicator>
        <cog-icon-sign-in-indicator style="color: #F57C00;"></cog-icon-sign-in-indicator>
      </div>
    `,
  }),
};

export const DifferentSizes: Story = {
  render: () => ({
    template: `
      <div style="display: flex; gap: 10px; align-items: center;">
        <cog-icon-sign-in-indicator style="--cog-icon-size: 16px;"></cog-icon-sign-in-indicator>
        <cog-icon-sign-in-indicator style="--cog-icon-size: 24px;"></cog-icon-sign-in-indicator>
        <cog-icon-sign-in-indicator style="--cog-icon-size: 32px;"></cog-icon-sign-in-indicator>
        <cog-icon-sign-in-indicator style="--cog-icon-size: 48px;"></cog-icon-sign-in-indicator>
        <cog-icon-sign-in-indicator style="--cog-icon-size: 64px;"></cog-icon-sign-in-indicator>
      </div>
    `,
  }),
};
