import type { Meta, StoryObj } from '@storybook/angular';

import { Button } from './button.component';

const meta: Meta<Button> = {
  component: Button,
  title: 'Core/Components/Common/Button',
  render: (args) => ({
    props: args,
    template: `<button cog-button ${args.primary ? 'primary' : ''} ${args.secondary ? 'secondary' : ''} ${args.filled ? 'filled' : ''} ${args.outlined ? 'outlined' : ''} ${args.disabled ? 'disabled' : ''}>Button Text</button>`,
  }),
  argTypes: {
    primary: { control: 'boolean' },
    secondary: { control: 'boolean' },
    filled: { control: 'boolean' },
    outlined: { control: 'boolean' },
    disabled: { control: 'boolean' },
  },
};
export default meta;

type Story = StoryObj<Button>;

// Primary button variations
export const PrimaryFilled: Story = {
  args: {
    primary: true,
    filled: true,
  },
};

export const PrimaryOutlined: Story = {
  args: {
    primary: true,
    outlined: true,
  },
};

export const PrimaryDisabled: Story = {
  args: {
    primary: true,
    filled: true,
    disabled: true,
  },
};

// Secondary button variations
export const SecondaryFilled: Story = {
  args: {
    secondary: true,
    filled: true,
  },
};

export const SecondaryOutlined: Story = {
  args: {
    secondary: true,
    outlined: true,
  },
};

export const SecondaryDisabled: Story = {
  args: {
    secondary: true,
    filled: true,
    disabled: true,
  },
};

// Default button (no color specified)
export const DefaultFilled: Story = {
  args: {
    filled: true,
  },
};

export const DefaultOutlined: Story = {
  args: {
    outlined: true,
  },
};

// Interactive example
export const Interactive: Story = {
  args: {
    primary: true,
    filled: true,
  },
  render: () => ({
    template: `
      <div style="display: flex; flex-direction: column; gap: 20px; padding: 20px;">
        <div style="display: flex; gap: 10px; align-items: center;">
          <button cog-button primary filled>Primary Filled</button>
          <button cog-button primary outlined>Primary Outlined</button>
          <button cog-button primary filled disabled>Primary Disabled</button>
        </div>
        <div style="display: flex; gap: 10px; align-items: center;">
          <button cog-button secondary filled>Secondary Filled</button>
          <button cog-button secondary outlined>Secondary Outlined</button>
          <button cog-button secondary filled disabled>Secondary Disabled</button>
        </div>
        <div style="display: flex; gap: 10px; align-items: center;">
          <a cog-button primary filled href="#">Link as Button</a>
          <a cog-button secondary outlined href="#">Link Outlined</a>
        </div>
      </div>
    `,
  }),
};
