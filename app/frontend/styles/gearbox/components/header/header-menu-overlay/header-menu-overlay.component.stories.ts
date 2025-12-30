import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { Button } from '../../common/button/button.component';
import { SignInIndicatorIcon } from '../../icons/icon-sign-in-indicator/sign-in-indicator.icon';
import { SignUpIndicatorIcon } from '../../icons/icon-sign-up-indicator/sign-up-indicator.icon';
import { LegalLink } from '../../legal/legal-link/legal-link.component';
import { LegalLinks } from '../../legal/legal-links/legal-links.component';
import { MenuItem } from '../../menu/menu-item/menu-item.component';
import { MenuItemsComponent } from '../../menu/menu-items/menu-items.component';
import { SnsItem } from '../../social/sns-item/sns-item.component';
import { SnsItems } from '../../social/sns-items/sns-items.component';
import { HeaderMenuBannerComponent } from '../header-menu-banner/header-menu-banner.component';
import { HeaderMenuBannersComponent } from '../header-menu-banners/header-menu-banners.component';
import { HeaderMenuOverlayActions } from '../header-menu-overlay-actions/header-menu-overlay-actions.component';
import { HeaderMenuOverlayContentComponent } from '../header-menu-overlay-content/header-menu-overlay-content.component';
import { HeaderMenuOverlayFooterComponent } from '../header-menu-overlay-footer/header-menu-overlay-footer.component';
import { HeaderMenuOverlayHeadComponent } from '../header-menu-overlay-head/header-menu-overlay-head.component';
import { HeaderMenuOverlayComponent } from './header-menu-overlay.component';

const meta: Meta<HeaderMenuOverlayComponent> = {
  component: HeaderMenuOverlayComponent,
  title: 'Core/Components/Header/HeaderMenuOverlay',
  decorators: [
    moduleMetadata({
      imports: [
        HeaderMenuOverlayHeadComponent,
        HeaderMenuOverlayActions,
        Button,
        SignUpIndicatorIcon,
        SignInIndicatorIcon,
        HeaderMenuOverlayContentComponent,
        HeaderMenuOverlayFooterComponent,
        MenuItemsComponent,
        MenuItem,
        SnsItems,
        SnsItem,
        LegalLinks,
        LegalLink,
        HeaderMenuBannersComponent,
        HeaderMenuBannerComponent,
      ],
    }),
  ],
  parameters: {
    viewport: {
      defaultViewport: 'mobile1',
      canvas: {
        width: 390,
        height: 844,
      },
    },
  },
};
export default meta;

type Story = StoryObj<HeaderMenuOverlayComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <cog-header-menu-overlay class="show">
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

          <!-- content -->
          <cog-header-menu-overlay-content>
            <cog-menu-items>
              <a cog-menu-item href="#">TOP</a>
              <a cog-menu-item href="#">NEWS</a>
              <a cog-menu-item href="#">TICKET</a>
              <a cog-menu-item href="#">BLOG</a>
              <a cog-menu-item href="#">SCHEDULE</a>
              <a cog-menu-item href="#">MYPAGE</a>
            </cog-menu-items>

            <cog-sns-items>
              <a cog-sns-item [type]="'line'" href="https://line.me/example" target="_blank"></a>
              <a cog-sns-item [type]="'x'" href="https://x.com/example" target="_blank"></a>
              <a cog-sns-item [type]="'instagram'" href="https://instagram.com/example" target="_blank"></a>
              <a cog-sns-item [type]="'youtube'" href="https://youtube.com/@example" target="_blank"></a>
            </cog-sns-items>
          </cog-header-menu-overlay-content>

          <!-- footer -->
          <cog-header-menu-overlay-footer>
            <cog-header-menu-banners>
              <a cog-header-menu-banner href="#">
                <img src="assets/images/dummy-banner-1.png" alt="Header Menu Banner 1">
              </a>
              <a cog-header-menu-banner href="#">
                <img src="assets/images/dummy-banner-2.png" alt="Header Menu Banner 2">
              </a>
              <a cog-header-menu-banner href="#">
                <img src="assets/images/dummy-banner-3.png" alt="Header Menu Banner 3">
              </a>
            </cog-header-menu-banners>
          </cog-header-menu-overlay-footer>
        </cog-header-menu-overlay>
      </div>
    `,
  }),
};
