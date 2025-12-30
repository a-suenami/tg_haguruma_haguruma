import type { Meta, StoryObj } from '@storybook/angular';
import { DetailFragmentContent } from './detail-fragment-content.component';
import { expect } from 'storybook/test';

const meta: Meta<DetailFragmentContent> = {
  component: DetailFragmentContent,
  title: 'Core/Components/Fragments/Detail/DetailFragmentContent',
};
export default meta;

type Story = StoryObj<DetailFragmentContent>;

export const Primary: Story = {
  args: {},
};

export const Heading: Story = {
  args: {},
  play: async ({ canvas }) => {
    await expect(canvas.getByText(/detail-fragment-content/gi)).toBeTruthy();
  },
};
