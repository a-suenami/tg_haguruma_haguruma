import type { Meta, StoryObj } from '@storybook/angular';
import { ListFragmentTitle } from './list-fragment-title.component';
import { expect } from 'storybook/test';

const meta: Meta<ListFragmentTitle> = {
  component: ListFragmentTitle,
  title: 'Core/Components/Fragments/List/ListFragmentTitle',
};
export default meta;

type Story = StoryObj<ListFragmentTitle>;

export const Primary: Story = {
  args: {},
};

export const Heading: Story = {
  args: {},
  play: async ({ canvas }) => {
    await expect(canvas.getByText(/list-fragment-title/gi)).toBeTruthy();
  },
};
