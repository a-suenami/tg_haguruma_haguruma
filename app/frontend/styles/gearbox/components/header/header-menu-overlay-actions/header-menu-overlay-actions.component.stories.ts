import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { Button } from '../../common/button/button.component';
import { HeaderMenuOverlayActions } from './header-menu-overlay-actions.component';

const meta: Meta<HeaderMenuOverlayActions> = {
  component: HeaderMenuOverlayActions,
  title: 'Core/Components/Header/HeaderMenuOverlayActions',
  decorators: [
    moduleMetadata({
      imports: [Button],
    }),
  ],
};
export default meta;

type Story = StoryObj<HeaderMenuOverlayActions>;

export const Default: Story = {
  render: () => ({
    imports: [Button],
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background-secondary); width: 390px; margin: 0 auto;">
        <cog-header-menu-overlay-actions>
          <button cog-button primary filled style="width: 176px;">
            ログイン
          </button>
          <button cog-button primary outlined style="width: 176px;">
            新規会員登録
          </button>
        </cog-header-menu-overlay-actions>
      </div>
    `,
  }),
};

export const SingleButton: Story = {
  render: () => ({
    imports: [Button],
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background-secondary); width: 390px; margin: 0 auto;">
        <cog-header-menu-overlay-actions>
          <button cog-button primary filled style="width: 100%;">
            ログインして続ける
          </button>
        </cog-header-menu-overlay-actions>
      </div>
    `,
  }),
};
