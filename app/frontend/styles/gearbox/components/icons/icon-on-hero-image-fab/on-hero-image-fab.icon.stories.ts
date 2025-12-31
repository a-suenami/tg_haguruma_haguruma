import type { Meta, StoryObj } from '@storybook/angular';

import { OnHeroImageFabIcon } from './on-hero-image-fab.icon';

const meta: Meta<OnHeroImageFabIcon> = {
  component: OnHeroImageFabIcon,
  title: 'Core/Components/Icons/OnHeroImageFabIcon',
  render: () => ({
    template: `<cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>`,
  }),
};
export default meta;

type Story = StoryObj<OnHeroImageFabIcon>;

export const Default: Story = {};

export const CustomColor: Story = {
  render: () => ({
    template: `
      <div style="display: flex; gap: 10px; align-items: center;">
        <cog-icon-on-hero-image-fab style="color: #1976D2;"></cog-icon-on-hero-image-fab>
        <cog-icon-on-hero-image-fab style="color: #DC004E;"></cog-icon-on-hero-image-fab>
        <cog-icon-on-hero-image-fab style="color: #388E3C;"></cog-icon-on-hero-image-fab>
        <cog-icon-on-hero-image-fab style="color: #F57C00;"></cog-icon-on-hero-image-fab>
      </div>
    `,
  }),
};

export const DifferentSizes: Story = {
  render: () => ({
    template: `
      <div style="display: flex; gap: 10px; align-items: center;">
        <cog-icon-on-hero-image-fab style="--cog-icon-size: 16px;"></cog-icon-on-hero-image-fab>
        <cog-icon-on-hero-image-fab style="--cog-icon-size: 24px;"></cog-icon-on-hero-image-fab>
        <cog-icon-on-hero-image-fab style="--cog-icon-size: 32px;"></cog-icon-on-hero-image-fab>
        <cog-icon-on-hero-image-fab style="--cog-icon-size: 48px;"></cog-icon-on-hero-image-fab>
        <cog-icon-on-hero-image-fab style="--cog-icon-size: 64px;"></cog-icon-on-hero-image-fab>
      </div>
    `,
  }),
};
