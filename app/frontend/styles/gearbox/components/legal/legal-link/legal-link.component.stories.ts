import type { Meta, StoryObj } from '@storybook/angular';

import { LegalLink } from './legal-link.component';

const meta: Meta<LegalLink> = {
  component: LegalLink,
  title: 'Core/Components/Legal/LegalLink',
};
export default meta;

type Story = StoryObj<LegalLink>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <a cog-legal-link href="#">Legal link</a>
      </div>
    `,
  }),
};
