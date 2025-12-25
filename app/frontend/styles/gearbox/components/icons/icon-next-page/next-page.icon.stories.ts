import type { Meta, StoryObj } from '@storybook/angular';

import { NextPageIcon } from './next-page.icon';

const meta: Meta<NextPageIcon> = {
  component: NextPageIcon,
  title: 'Core/Components/Icons/NextPageIcon',
  render: () => ({
    template: `<cog-icon-next-page></cog-icon-next-page>`,
  }),
};
export default meta;

type Story = StoryObj<NextPageIcon>;

export const Default: Story = {};

export const CustomColor: Story = {
  render: () => ({
    template: `
      <div style="display: flex; gap: 10px; align-items: center;">
        <cog-icon-next-page style="color: #1976D2;"></cog-icon-next-page>
        <cog-icon-next-page style="color: #DC004E;"></cog-icon-next-page>
        <cog-icon-next-page style="color: #388E3C;"></cog-icon-next-page>
        <cog-icon-next-page style="color: #F57C00;"></cog-icon-next-page>
      </div>
    `,
  }),
};

export const DifferentSizes: Story = {
  render: () => ({
    template: `
      <div style="display: flex; gap: 10px; align-items: center;">
        <cog-icon-next-page style="--cog-icon-size: 16px;"></cog-icon-next-page>
        <cog-icon-next-page style="--cog-icon-size: 24px;"></cog-icon-next-page>
        <cog-icon-next-page style="--cog-icon-size: 32px;"></cog-icon-next-page>
        <cog-icon-next-page style="--cog-icon-size: 48px;"></cog-icon-next-page>
        <cog-icon-next-page style="--cog-icon-size: 64px;"></cog-icon-next-page>
      </div>
    `,
  }),
};
