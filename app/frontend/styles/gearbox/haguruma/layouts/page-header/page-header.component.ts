import {
  ChangeDetectionStrategy,
  Component,
  inject,
  viewChild,
} from '@angular/core';
import { RouterLink } from '@angular/router';

import {
  Button,
  Header,
  HeaderLogoButton,
  HeaderMenu,
  HeaderMenuBannerComponent,
  HeaderMenuBannersComponent,
  HeaderMenuButton,
  HeaderMenuItem,
  HeaderMenuOverlayActions,
  HeaderMenuOverlayComponent,
  HeaderMenuOverlayContentComponent,
  HeaderMenuOverlayFooterComponent,
  HeaderMenuOverlayHeadComponent,
  Logo,
  MenuItem,
  MenuItemsComponent,
  SignInIndicatorIcon,
  SignUpIndicatorIcon,
  SnsItem,
  SnsItems,
} from '@gearbox/ui';

import { HAGURUMA_CONFIG } from '../../../shared/config/haguruma-config.token';
import { HasFeaturePipe } from '../../../shared/pipes/has-feature.pipe';
import {
  AuthenticationPath,
  ExternalNavigationService,
} from '../../../shared/services/external-navigation.service';

@Component({
  selector: 'cog-page-header',

  imports: [
    RouterLink,
    Header,
    HeaderLogoButton,
    HeaderMenu,
    HeaderMenuItem,
    HeaderMenuButton,
    HeaderMenuOverlayComponent,
    HeaderMenuOverlayHeadComponent,
    HeaderMenuOverlayActions,
    HeaderMenuOverlayContentComponent,
    HeaderMenuOverlayFooterComponent,
    HeaderMenuBannersComponent,
    HeaderMenuBannerComponent,
    Logo,
    Button,
    MenuItemsComponent,
    MenuItem,
    SnsItems,
    SnsItem,
    SignUpIndicatorIcon,
    SignInIndicatorIcon,
    HasFeaturePipe,
  ],
  templateUrl: './page-header.component.html',
  styleUrl: './page-header.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PageHeaderComponent {
  private readonly config = inject(HAGURUMA_CONFIG);
  private readonly navigation = inject(ExternalNavigationService);

  readonly overlay = viewChild.required<HeaderMenuOverlayComponent>(
    HeaderMenuOverlayComponent,
  );

  protected readonly features = this.config.features;
  protected readonly snsLinks = Object.values(
    this.config.predefinedSNSLinks,
  ).filter((link) => link.enabled);

  presentOverlay(): void {
    this.overlay().present();
  }

  dismissOverlay(): void {
    this.overlay().dismiss();
  }

  openAuthentication(path: AuthenticationPath): void {
    this.navigation.openAuthenticationPage(path);
  }

  openMembership(): void {
    this.navigation.openMembershipPurchasePage('membership-plan/select');
  }

  openMyPage(): void {
    this.navigation.openMyPage('mypage');
  }
}
