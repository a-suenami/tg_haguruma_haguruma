import type { Meta, StoryObj } from '@storybook/angular';

import { DownTriangleIcon } from './down-triangle.icon';

const meta: Meta<DownTriangleIcon> = {
  title: 'Core/Components/Icons/DownTriangle',
  component: DownTriangleIcon,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<DownTriangleIcon>;

const wrapper = (content: string) => `
  <div style="
    padding: 2rem;
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: var(--gearbox-background);
    border: 1px solid var(--gearbox-outline-primary);
  ">
    ${content}
  </div>
`;

export const Default: Story = {
  render: () => ({
    template: wrapper(`<cog-icon-down-triangle></cog-icon-down-triangle>`),
  }),
};
