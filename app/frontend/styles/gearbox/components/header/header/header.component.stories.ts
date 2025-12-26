import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { Button } from '../../common/button/button.component';
import { SignInIndicatorIcon } from '../../icons/icon-sign-in-indicator/sign-in-indicator.icon';
import { SignUpIndicatorIcon } from '../../icons/icon-sign-up-indicator/sign-up-indicator.icon';
import { LegalLink } from '../../legal/legal-link/legal-link.component';
import { LegalLinks } from '../../legal/legal-links/legal-links.component';
import { Logo } from '../../logo/logo/logo.component';
import { MenuItem } from '../../menu/menu-item/menu-item.component';
import { MenuItemsComponent } from '../../menu/menu-items/menu-items.component';
import { SnsItem } from '../../social/sns-item/sns-item.component';
import { SnsItems } from '../../social/sns-items/sns-items.component';
import { HeaderLogoButton } from '../header-logo-button/header-logo-button.component';
import { HeaderMenuBannerComponent } from '../header-menu-banner/header-menu-banner.component';
import { HeaderMenuBannersComponent } from '../header-menu-banners/header-menu-banners.component';
import { HeaderMenuButton } from '../header-menu-button/header-menu-button.component';
import { HeaderMenuItem } from '../header-menu-item/header-menu-item.component';
import { HeaderMenuOverlayActions } from '../header-menu-overlay-actions/header-menu-overlay-actions.component';
import { HeaderMenuOverlayContentComponent } from '../header-menu-overlay-content/header-menu-overlay-content.component';
import { HeaderMenuOverlayFooterComponent } from '../header-menu-overlay-footer/header-menu-overlay-footer.component';
import { HeaderMenuOverlayHeadComponent } from '../header-menu-overlay-head/header-menu-overlay-head.component';
import { HeaderMenuOverlayComponent } from '../header-menu-overlay/header-menu-overlay.component';
import { HeaderMenu } from '../header-menu/header-menu.component';
import { Header } from './header.component';

const meta: Meta<Header> = {
  component: Header,
  title: 'Core/Components/Header/Header',
  decorators: [
    moduleMetadata({
      imports: [
        HeaderLogoButton,
        HeaderMenu,
        HeaderMenuItem,
        Logo,
        HeaderMenuButton,
        HeaderMenuOverlayComponent,
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
};
export default meta;

type Story = StoryObj<Header>;

export const Default: Story = {
  parameters: {
    layout: 'fullscreen',
  },
  render: () => ({
    template: `
    <div style="background-color: blue;">
      <header cog-header>
        <cog-header-logo-button>
          <cog-logo></cog-logo>
        </cog-header-logo-button>

        <cog-header-menu>
          <a href="#" cog-header-menu-item>NEWS</a>
          <a href="#" cog-header-menu-item>TICKET</a>
          <a href="#" cog-header-menu-item>BLOG</a>
          <a href="#" cog-header-menu-item>SCHEDULE</a>
          <a href="#" cog-header-menu-item>MY PAGE</a>
        </cog-header-menu>

        <button
          type="button"
          cog-header-menu-button
          (present)="overlay.present()"
          (dismiss)="overlay.dismiss()"
        ></button>

        <cog-header-menu-overlay #overlay>
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
      </header>
    </div>
    `,
  }),
};
