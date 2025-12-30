import type { Meta, StoryObj } from '@storybook/angular';

import { CheckIcon } from './check.icon';

const meta: Meta<CheckIcon> = {
  title: 'Core/Components/Icons/CheckIcon',
  component: CheckIcon,
  tags: ['autodocs'],
  parameters: {
    docs: {
      description: {
        component:
          'Tick icon component used to represent confirmation or success states.',
      },
    },
  },
};

export default meta;
type Story = StoryObj<CheckIcon>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background: var(--gearbox-background); display: flex; gap: 1rem; align-items: center;">
        <cog-icon-check></cog-icon-check>
        <span>標準のチェックアイコン</span>
      </div>
    `,
  }),
};

export const Sizes: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background: var(--gearbox-background); display: flex; gap: 2rem; flex-wrap: wrap;">
        <div style="text-align: center;">
          <cog-icon-check style="--cog-icon-size: 12px;"></cog-icon-check>
          <p style="margin-top: 0.5rem; font-size: 12px;">12px</p>
        </div>
        <div style="text-align: center;">
          <cog-icon-check style="--cog-icon-size: 16px;"></cog-icon-check>
          <p style="margin-top: 0.5rem; font-size: 12px;">16px</p>
        </div>
        <div style="text-align: center;">
          <cog-icon-check style="--cog-icon-size: 24px;"></cog-icon-check>
          <p style="margin-top: 0.5rem; font-size: 12px;">24px (default)</p>
        </div>
        <div style="text-align: center;">
          <cog-icon-check style="--cog-icon-size: 32px;"></cog-icon-check>
          <p style="margin-top: 0.5rem; font-size: 12px;">32px</p>
        </div>
      </div>
    `,
  }),
};

export const OnAccentBackground: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background: var(--gearbox-primary); display: inline-flex; flex-direction: column; gap: 1rem; color: white;">
        <div style="display: flex; gap: 0.75rem; align-items: center;">
          <cog-icon-check style="--cog-icon-size: 20px; filter: brightness(0) invert(1);"></cog-icon-check>
          <span>アクションが完了しました</span>
        </div>
        <button style="background: transparent; border: 1px solid rgba(255,255,255,0.4); border-radius: 999px; color: white; padding: 0.5rem 1rem; display: inline-flex; align-items: center; gap: 0.5rem;">
          <cog-icon-check style="--cog-icon-size: 16px; filter: brightness(0) invert(1);"></cog-icon-check>
          完了済み
        </button>
      </div>
    `,
  }),
};
