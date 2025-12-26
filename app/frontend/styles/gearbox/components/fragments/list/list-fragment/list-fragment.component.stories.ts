import type { Meta, StoryObj } from '@storybook/angular';
import { ListFragment } from './list-fragment.component';
import { expect } from 'storybook/test';

const meta: Meta<ListFragment> = {
  component: ListFragment,
  title: 'Core/Components/Fragments/List/ListFragment',
};
export default meta;

type Story = StoryObj<ListFragment>;

export const Primary: Story = {
  args: {},
};

export const Heading: Story = {
  args: {},
  play: async ({ canvas }) => {
    await expect(canvas.getByText(/list-fragment/gi)).toBeTruthy();
  },
};
