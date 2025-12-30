import type { Meta, StoryObj } from '@storybook/angular';
import { DetailFragmentTitle } from './detail-fragment-title.component';
import { expect } from 'storybook/test';

const meta: Meta<DetailFragmentTitle> = {
  component: DetailFragmentTitle,
  title: 'Core/Components/Fragments/Detail/DetailFragmentTitle',
};
export default meta;

type Story = StoryObj<DetailFragmentTitle>;

export const Primary: Story = {
  args: {},
};

export const Heading: Story = {
  args: {},
  play: async ({ canvas }) => {
    await expect(canvas.getByText(/detail-fragment-title/gi)).toBeTruthy();
  },
};
