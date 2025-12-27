import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';

import {
  Button,
  SignInIndicatorIcon,
  SignUpIndicatorIcon,
  SwiperContainer,
  SwiperSlide,
} from '@gearbox/ui';

import { FeatureTitleImageComponent } from '../../../../shared/components/feature-title-image/feature-title-image.component';
import { HAGURUMA_CONFIG } from '../../../../shared/config/haguruma-config.token';
import { PageFooterComponent } from '../../../../shared/layouts/page-footer/page-footer.component';
import { PageHeaderComponent } from '../../../../shared/layouts/page-header/page-header.component';
import { HasFeaturePipe } from '../../../../shared/pipes/has-feature.pipe';
import {
  AuthenticationPath,
  ExternalNavigationService,
  MembershipPath,
} from '../../../../shared/services/external-navigation.service';
import { NewsListComponent } from '../../../news/components/news-list/news-list.component';
import { LandingBannerComponent } from '../../components/landing-banner/landing-banner.component';
import { LandingHeroImageComponent } from '../../components/landing-hero-image/landing-hero-image.component';
import { LandingSectionActionsComponent } from '../../components/landing-section-actions/landing-section-actions.component';
import { LandingSectionContentComponent } from '../../components/landing-section-content/landing-section-content.component';
import { LandingSectionTitleComponent } from '../../components/landing-section-title/landing-section-title.component';
import { LandingSectionComponent } from '../../components/landing-section/landing-section.component';

@Component({
  selector: 'cog-landing-page',
  imports: [
    CommonModule,
    PageHeaderComponent,
    PageFooterComponent,
    Button,
    SignUpIndicatorIcon,
    SignInIndicatorIcon,
    LandingHeroImageComponent,
    LandingSectionComponent,
    LandingSectionActionsComponent,
    SwiperContainer,
    SwiperSlide,
    LandingBannerComponent,
    LandingSectionTitleComponent,
    LandingSectionContentComponent,
    NewsListComponent,
    FeatureTitleImageComponent,
    HasFeaturePipe,
  ],
  templateUrl: './landing.page.html',
  styleUrl: './landing.page.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LandingPage {
  private readonly config = inject(HAGURUMA_CONFIG);
  protected readonly features = this.config.features;

  private readonly navigation = inject(ExternalNavigationService);

  openAuthenticationPage(path: AuthenticationPath): void {
    this.navigation.openAuthenticationPage(path);
  }

  openMembershipPage(path: MembershipPath): void {
    this.navigation.openMembershipPurchasePage(path);
  }
}
