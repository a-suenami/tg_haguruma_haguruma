import type { Meta, StoryObj } from '@storybook/angular';

import { BackArrowIcon } from './back-arrow.icon';

const meta: Meta<BackArrowIcon> = {
  title: 'Core/Components/Icons/BackArrowIcon',
  component: BackArrowIcon,
  tags: ['autodocs'],
  parameters: {
    docs: {
      description: {
        component: 'Back arrow icon component for navigation.',
      },
    },
  },
};

export default meta;
type Story = StoryObj<BackArrowIcon>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background: var(--gearbox-background);">
        <cog-icon-back-arrow></cog-icon-back-arrow>
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
            <cog-icon-back-arrow style="--cog-icon-size: 16px;"></cog-icon-back-arrow>
            <p style="margin-top: 0.5rem; font-size: 12px;">16px</p>
          </div>

          <div style="text-align: center;">
            <cog-icon-back-arrow style="--cog-icon-size: 24px;"></cog-icon-back-arrow>
            <p style="margin-top: 0.5rem; font-size: 12px;">24px (default)</p>
          </div>

          <div style="text-align: center;">
            <cog-icon-back-arrow style="--cog-icon-size: 32px;"></cog-icon-back-arrow>
            <p style="margin-top: 0.5rem; font-size: 12px;">32px</p>
          </div>

          <div style="text-align: center;">
            <cog-icon-back-arrow style="--cog-icon-size: 48px;"></cog-icon-back-arrow>
            <p style="margin-top: 0.5rem; font-size: 12px;">48px</p>
          </div>
        </div>
      </div>
    `,
  }),
};
