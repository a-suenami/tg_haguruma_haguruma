import type { Meta, StoryObj } from '@storybook/angular';
import { ListFragmentActions } from './list-fragment-actions.component';
import { expect } from 'storybook/test';

const meta: Meta<ListFragmentActions> = {
  component: ListFragmentActions,
  title: 'Core/Components/Fragments/List/ListFragmentActions',
};
export default meta;

type Story = StoryObj<ListFragmentActions>;

export const Primary: Story = {
  args: {},
};

export const Heading: Story = {
  args: {},
  play: async ({ canvas }) => {
    await expect(canvas.getByText(/list-fragment-actions/gi)).toBeTruthy();
  },
};
