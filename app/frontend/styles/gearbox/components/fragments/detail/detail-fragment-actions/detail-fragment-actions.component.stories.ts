import type { Meta, StoryObj } from '@storybook/angular';
import { DetailFragmentActions } from './detail-fragment-actions.component';
import { expect } from 'storybook/test';

const meta: Meta<DetailFragmentActions> = {
  component: DetailFragmentActions,
  title: 'Core/Components/Fragments/Detail/DetailFragmentActions',
};
export default meta;

type Story = StoryObj<DetailFragmentActions>;

export const Primary: Story = {
  args: {},
};

export const Heading: Story = {
  args: {},
  play: async ({ canvas }) => {
    await expect(canvas.getByText(/detail-fragment-actions/gi)).toBeTruthy();
  },
};
