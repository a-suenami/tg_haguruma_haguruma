import type { Meta, StoryObj } from '@storybook/angular';
import { DetailFragment } from './detail-fragment.component';
import { expect } from 'storybook/test';

const meta: Meta<DetailFragment> = {
  component: DetailFragment,
  title: 'Core/Components/Fragments/Detail/DetailFragment',
};
export default meta;

type Story = StoryObj<DetailFragment>;

export const Primary: Story = {
  args: {},
};

export const Heading: Story = {
  args: {},
  play: async ({ canvas }) => {
    await expect(canvas.getByText(/detail-fragment/gi)).toBeTruthy();
  },
};
