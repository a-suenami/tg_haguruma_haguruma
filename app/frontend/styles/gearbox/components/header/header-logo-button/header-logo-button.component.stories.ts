import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { Logo } from '../../logo/logo/logo.component';
import { HeaderLogoButton } from './header-logo-button.component';

const meta: Meta<HeaderLogoButton> = {
  component: HeaderLogoButton,
  title: 'Core/Components/Header/HeaderLogoButton',
  decorators: [
    moduleMetadata({
      imports: [Logo],
    }),
  ],
  argTypes: {
    href: {
      control: { type: 'text' },
      description: 'URL for the logo link',
    },
    ariaLabel: {
      control: { type: 'text' },
      description: 'Accessibility label for the logo link',
    },
  },
};
export default meta;

type Story = StoryObj<HeaderLogoButton>;

export const Default: Story = {
  args: {
    href: '/',
    ariaLabel: 'Home',
  },
  render: (args) => ({
    props: args,
    imports: [Logo],
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <cog-header-logo-button [href]="href" [ariaLabel]="ariaLabel">
          <cog-logo></cog-logo>
        </cog-header-logo-button>
      </div>
    `,
  }),
};
