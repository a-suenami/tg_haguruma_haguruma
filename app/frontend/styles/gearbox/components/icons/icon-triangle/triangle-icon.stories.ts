import type { Meta, StoryObj } from '@storybook/angular';

import { TriangleIcon } from './triangle.icon';

const meta: Meta<TriangleIcon> = {
  title: 'Core/Components/Icons/TriangleIcon',
  component: TriangleIcon,
  tags: ['autodocs'],
  parameters: {
    docs: {
      description: {
        component: 'Triangle icon component for dropdowns and indicators.',
      },
    },
  },
};

export default meta;
type Story = StoryObj<TriangleIcon>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background: var(--gearbox-background);">
        <cog-icon-triangle></cog-icon-triangle>
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
            <cog-icon-triangle style="--cog-icon-size: 8px;"></cog-icon-triangle>
            <p style="margin-top: 0.5rem; font-size: 12px;">8px</p>
          </div>

          <div style="text-align: center;">
            <cog-icon-triangle style="--cog-icon-size: 12px;"></cog-icon-triangle>
            <p style="margin-top: 0.5rem; font-size: 12px;">12px</p>
          </div>

          <div style="text-align: center;">
            <cog-icon-triangle style="--cog-icon-size: 16px;"></cog-icon-triangle>
            <p style="margin-top: 0.5rem; font-size: 12px;">16px</p>
          </div>

          <div style="text-align: center;">
            <cog-icon-triangle style="--cog-icon-size: 24px;"></cog-icon-triangle>
            <p style="margin-top: 0.5rem; font-size: 12px;">24px (default)</p>
          </div>

          <div style="text-align: center;">
            <cog-icon-triangle style="--cog-icon-size: 32px;"></cog-icon-triangle>
            <p style="margin-top: 0.5rem; font-size: 12px;">32px</p>
          </div>
        </div>
      </div>
    `,
  }),
};

export const Rotations: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background: var(--gearbox-background);">
        <div style="display: flex; gap: 2rem; align-items: center; flex-wrap: wrap;">
          <div style="text-align: center;">
            <cog-icon-triangle style="--cog-icon-size: 24px;"></cog-icon-triangle>
            <p style="margin-top: 0.5rem; font-size: 12px;">Down (default)</p>
          </div>

          <div style="text-align: center;">
            <cog-icon-triangle style="--cog-icon-size: 24px; transform: rotate(90deg);"></cog-icon-triangle>
            <p style="margin-top: 0.5rem; font-size: 12px;">Right</p>
          </div>

          <div style="text-align: center;">
            <cog-icon-triangle style="--cog-icon-size: 24px; transform: rotate(180deg);"></cog-icon-triangle>
            <p style="margin-top: 0.5rem; font-size: 12px;">Up</p>
          </div>

          <div style="text-align: center;">
            <cog-icon-triangle style="--cog-icon-size: 24px; transform: rotate(270deg);"></cog-icon-triangle>
            <p style="margin-top: 0.5rem; font-size: 12px;">Left</p>
          </div>
        </div>
      </div>
    `,
  }),
};

export const InDropdown: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background: var(--gearbox-background);">
        <button style="background: white; border: 1px solid #e0e0e0; border-radius: 8px; padding: 8px 16px; display: inline-flex; align-items: center; gap: 8px; cursor: pointer;">
          <span>ドロップダウン</span>
          <cog-icon-triangle style="--cog-icon-size: 8px;"></cog-icon-triangle>
        </button>

        <div style="margin-top: 2rem;">
          <button style="background: var(--gearbox-primary); color: white; border: none; border-radius: 8px; padding: 12px 24px; display: inline-flex; align-items: center; gap: 12px; cursor: pointer; font-size: 16px;">
            <span>選択してください</span>
            <cog-icon-triangle style="--cog-icon-size: 10px; filter: brightness(0) invert(1);"></cog-icon-triangle>
          </button>
        </div>
      </div>
    `,
  }),
};
