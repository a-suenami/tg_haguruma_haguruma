import type { Meta, StoryObj } from '@storybook/angular';

import { ForwardArrowIcon } from './forward-arrow.icon';

const meta: Meta<ForwardArrowIcon> = {
  title: 'Core/Components/Icons/ForwardArrowIcon',
  component: ForwardArrowIcon,
  tags: ['autodocs'],
  parameters: {
    docs: {
      description: {
        component: 'Forward arrow icon component for navigation.',
      },
    },
  },
};

export default meta;
type Story = StoryObj<ForwardArrowIcon>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background: var(--gearbox-background);">
        <cog-icon-forward-arrow></cog-icon-forward-arrow>
      </div>
    `,
  }),
};

export const Sizes: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background: var(--gearbox-background);">
        <div style="display: flex; gap: 2rem; align-items: center; flex-wrap: wrap;">
          <div style="text-align: center;">
            <cog-icon-forward-arrow style="--cog-icon-size: 16px;"></cog-icon-forward-arrow>
            <p style="margin-top: 0.5rem; font-size: 12px;">16px</p>
          </div>

          <div style="text-align: center;">
            <cog-icon-forward-arrow style="--cog-icon-size: 24px;"></cog-icon-forward-arrow>
            <p style="margin-top: 0.5rem; font-size: 12px;">24px (default)</p>
          </div>

          <div style="text-align: center;">
            <cog-icon-forward-arrow style="--cog-icon-size: 32px;"></cog-icon-forward-arrow>
            <p style="margin-top: 0.5rem; font-size: 12px;">32px</p>
          </div>

          <div style="text-align: center;">
            <cog-icon-forward-arrow style="--cog-icon-size: 48px;"></cog-icon-forward-arrow>
            <p style="margin-top: 0.5rem; font-size: 12px;">48px</p>
          </div>
        </div>
      </div>
    `,
  }),
};
