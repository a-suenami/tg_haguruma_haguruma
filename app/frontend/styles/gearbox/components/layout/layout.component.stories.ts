import type { Meta, StoryObj } from '@storybook/angular';
import { Layout } from './layout.component';
import { expect } from 'storybook/test';

const meta: Meta<Layout> = {
  component: Layout,
  title: 'Core/Components/Layout/Layout',
};
export default meta;

type Story = StoryObj<Layout>;

export const Primary: Story = {
  args: {},
};

export const Heading: Story = {
  args: {},
  play: async ({ canvas }) => {
    await expect(canvas.getByText(/layout/gi)).toBeTruthy();
  },
};
