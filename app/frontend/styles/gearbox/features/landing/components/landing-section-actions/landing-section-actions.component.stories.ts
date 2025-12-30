import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { Button, SignInIndicatorIcon, SignUpIndicatorIcon } from '@gearbox/ui';

import { LandingSectionActionsComponent } from './landing-section-actions.component';

const meta: Meta<LandingSectionActionsComponent> = {
  component: LandingSectionActionsComponent,
  title: 'Features/Landing/Components/LandingSectionActions',
  decorators: [
    moduleMetadata({
      imports: [
        LandingSectionActionsComponent,
        Button,
        SignInIndicatorIcon,
        SignUpIndicatorIcon,
      ],
    }),
  ],
  parameters: {
    layout: 'centered',
  },
};
export default meta;

type Story = StoryObj<LandingSectionActionsComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="width: 600px; padding: 2rem; background: var(--gearbox-background, #f5f5f5);">
        <cog-landing-section-actions>
          <button cog-button filled style="--cog-button-width: 100%; --cog-button-align: space-between; flex: 1;">
            <span>ログイン</span>
            <cog-icon-sign-in-indicator />
          </button>
          <button cog-button outlined style="--cog-button-width: 100%; --cog-button-align: space-between; flex: 1;">
            <span>新規会員登録</span>
            <cog-icon-sign-up-indicator />
          </button>
        </cog-landing-section-actions>
      </div>
    `,
  }),
};
