import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { Button } from '../../common/button/button.component';
import { SignInIndicatorIcon } from '../../icons/icon-sign-in-indicator/sign-in-indicator.icon';
import { SignUpIndicatorIcon } from '../../icons/icon-sign-up-indicator/sign-up-indicator.icon';
import { HeaderMenuOverlayActions } from '../header-menu-overlay-actions/header-menu-overlay-actions.component';
import { HeaderMenuOverlayHeadComponent } from './header-menu-overlay-head.component';

const meta: Meta<HeaderMenuOverlayHeadComponent> = {
  component: HeaderMenuOverlayHeadComponent,
  title: 'Core/Components/Header/HeaderMenuOverlayHead',
  decorators: [
    moduleMetadata({
      imports: [
        HeaderMenuOverlayActions,
        Button,
        SignUpIndicatorIcon,
        SignInIndicatorIcon,
      ],
    }),
  ],
};
export default meta;

type Story = StoryObj<HeaderMenuOverlayHeadComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="display: block; position:relative; width: 390; height: 844px;">
        <cog-header-menu-overlay-head>
          <cog-header-menu-overlay-actions>
            <button cog-button filled style="--cog-button-width: 100%; --cog-button-align: space-between; flex: 1;">
              <span>ログイン</span>
              <cog-icon-sign-in-indicator />
            </button>
            <button cog-button outlined style="--cog-button-width: 100%; --cog-button-align: space-between; flex: 1;">
              <span>新規会員登録</span>
              <cog-icon-sign-up-indicator />
            </button>
          </cog-header-menu-overlay-actions>
        </cog-header-menu-overlay-head>
      </div>
    `,
  }),
};
