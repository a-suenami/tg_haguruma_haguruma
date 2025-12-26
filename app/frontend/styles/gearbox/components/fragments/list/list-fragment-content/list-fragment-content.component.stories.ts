import type { Meta, StoryObj } from '@storybook/angular';
import { ListFragmentContent } from './list-fragment-content.component';
import { expect } from 'storybook/test';

const meta: Meta<ListFragmentContent> = {
  component: ListFragmentContent,
  title: 'Core/Components/Fragments/List/ListFragmentContent',
};
export default meta;

type Story = StoryObj<ListFragmentContent>;

export const Primary: Story = {
  args: {},
};

export const Heading: Story = {
  args: {},
  play: async ({ canvas }) => {
    await expect(canvas.getByText(/list-fragment-content/gi)).toBeTruthy();
  },
};
