import type { Meta, StoryObj } from '@storybook/angular';

import { Copyright } from './copyright.component';

const meta: Meta<Copyright> = {
  component: Copyright,
  title: 'Core/Components/Copyright/Copyright',
};
export default meta;

type Story = StoryObj<Copyright>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <cog-copyright>&copy; 2025 Gearbox. All rights reserved.</cog-copyright>
      </div>
    `,
  }),
};
