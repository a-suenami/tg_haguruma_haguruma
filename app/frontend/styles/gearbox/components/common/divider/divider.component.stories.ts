import type { Meta, StoryObj } from '@storybook/angular';

import { DividerComponent } from './divider.component';

const meta: Meta<DividerComponent> = {
  title: 'Core/Components/Common/Divider',
  component: DividerComponent,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<DividerComponent>;

const wrapper = (inner: string) => `
  <div style="padding: 2rem; background-color: var(--gearbox-background);">
    ${inner}
  </div>
`;

export const Default: Story = {
  render: () => ({
    template: wrapper('<cog-divider></cog-divider>'),
  }),
};

export const OnCard: Story = {
  render: () => ({
    template: `
      <div style="
        padding: 2rem;
        background-color: var(--gearbox-background);
        display: flex;
        justify-content: center;
      ">
        <div style="
          width: 360px;
          background: white;
          padding: 1.5rem;
          border-radius: 0.75rem;
          box-shadow: 0 8px 24px rgba(0,0,0,0.08);
          display: flex;
          flex-direction: column;
          gap: 1rem;
        ">
          <p style="margin: 0;">Primary content area.</p>
          <cog-divider></cog-divider>
          <p style="margin: 0;">Secondary content separated by the divider.</p>
        </div>
      </div>
    `,
  }),
};

export const ListStack: Story = {
  render: () => ({
    template: `
      <div style="
        padding: 2rem;
        background-color: var(--gearbox-background);
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
        width: min(420px, 100%);
      ">
        <div style="padding: 0.5rem 0;">List item 1</div>
        <cog-divider></cog-divider>
        <div style="padding: 0.5rem 0;">List item 2</div>
        <cog-divider></cog-divider>
        <div style="padding: 0.5rem 0;">List item 3</div>
      </div>
    `,
  }),
};
