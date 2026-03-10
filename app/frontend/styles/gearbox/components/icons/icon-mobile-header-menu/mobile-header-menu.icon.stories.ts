import type { Meta, StoryObj } from '@storybook/angular';

import { MobileHeaderMenuIcon } from './mobile-header-menu.icon';

const meta: Meta<MobileHeaderMenuIcon> = {
  component: MobileHeaderMenuIcon,
  title: 'Core/Components/Icons/MobileHeaderMenuIcon',
  render: () => ({
    template: `<cog-icon-mobile-header-menu></cog-icon-mobile-header-menu>`,
  }),
};
export default meta;

type Story = StoryObj<MobileHeaderMenuIcon>;

export const Default: Story = {};

export const CustomColor: Story = {
  render: () => ({
    template: `
      <div style="display: flex; gap: 10px; align-items: center;">
        <cog-icon-mobile-header-menu style="color: #1976D2;"></cog-icon-mobile-header-menu>
        <cog-icon-mobile-header-menu style="color: #DC004E;"></cog-icon-mobile-header-menu>
        <cog-icon-mobile-header-menu style="color: #388E3C;"></cog-icon-mobile-header-menu>
        <cog-icon-mobile-header-menu style="color: #F57C00;"></cog-icon-mobile-header-menu>
      </div>
    `,
  }),
};

export const DifferentSizes: Story = {
  render: () => ({
    template: `
      <div style="display: flex; gap: 10px; align-items: center;">
        <cog-icon-mobile-header-menu style="--cog-icon-size: 16px;"></cog-icon-mobile-header-menu>
        <cog-icon-mobile-header-menu style="--cog-icon-size: 24px;"></cog-icon-mobile-header-menu>
        <cog-icon-mobile-header-menu style="--cog-icon-size: 32px;"></cog-icon-mobile-header-menu>
        <cog-icon-mobile-header-menu style="--cog-icon-size: 48px;"></cog-icon-mobile-header-menu>
        <cog-icon-mobile-header-menu style="--cog-icon-size: 64px;"></cog-icon-mobile-header-menu>
      </div>
    `,
  }),
};
