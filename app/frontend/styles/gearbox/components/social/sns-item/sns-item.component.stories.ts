import type { Meta, StoryObj } from '@storybook/angular';

import { SnsItem } from './sns-item.component';

const meta: Meta<SnsItem> = {
  component: SnsItem,
  title: 'Core/Components/Social/SnsItem',
  argTypes: {
    type: {
      control: 'select',
      options: ['line', 'x', 'instagram', 'youtube'],
      description: 'The type of social media platform',
    },
    label: {
      control: 'text',
      description: 'Accessibility label for the link',
    },
  },
};
export default meta;

type Story = StoryObj<SnsItem>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background); display: flex; gap: 1rem; align-items: center;">
        <a cog-sns-item [type]="'line'" href="#" target="_blank"></a>
        <a cog-sns-item [type]="'x'" href="#" target="_blank"></a>
        <a cog-sns-item [type]="'instagram'" href="#" target="_blank"></a>
        <a cog-sns-item [type]="'youtube'" href="#" target="_blank"></a>
      </div>
    `,
  }),
};

export const Line: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <a cog-sns-item
          [type]="'line'"
          [label]="'LINE公式アカウント'"
          href="https://line.me/example"
          target="_blank">
        </a>
      </div>
    `,
  }),
};

export const X: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <a cog-sns-item
          [type]="'x'"
          [label]="'X (Twitter)'"
          href="https://x.com/example"
          target="_blank">
        </a>
      </div>
    `,
  }),
};

export const Instagram: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <a cog-sns-item
          [type]="'instagram'"
          [label]="'Instagram'"
          href="https://instagram.com/example"
          target="_blank">
        </a>
      </div>
    `,
  }),
};

export const YouTube: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <a cog-sns-item
          [type]="'youtube'"
          [label]="'YouTube Channel'"
          href="https://youtube.com/@example"
          target="_blank">
        </a>
      </div>
    `,
  }),
};
