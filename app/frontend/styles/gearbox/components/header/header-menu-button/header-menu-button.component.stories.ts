import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { HeaderMenuButton } from './header-menu-button.component';

const meta: Meta<HeaderMenuButton> = {
  component: HeaderMenuButton,
  title: 'Core/Components/Header/HeaderMenuButton',
  decorators: [
    moduleMetadata({
      imports: [],
    }),
  ],
  argTypes: {
    present: {
      action: 'present',
      description: 'Event emitted when button is clicked',
    },
    dismiss: {
      action: 'dismiss',
      description: 'Event emitted when button is clicked',
    },
  },
  parameters: {
    viewport: {
      defaultViewport: 'mobile1',
    },
  },
};
export default meta;

type Story = StoryObj<HeaderMenuButton>;

export const Default: Story = {
  render: (args) => ({
    props: args,
    template: `
      <div
        style="
          height: 100vh;
          width: 100vw;
        ">
        <button
          cog-header-menu-button
          type="button"
        >
        </button>
      </div>
    `,
  }),
};
