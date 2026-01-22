import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { RouterLink } from '@angular/router';

import {
  Copyright,
  Footer,
  FooterMenu,
  FooterMenuItem,
  LegalLink,
  LegalLinks,
  SnsItem,
  SnsItems,
} from '@gearbox/ui';

import { HAGURUMA_CONFIG } from '../../config/haguruma-config.token';
import { HasFeaturePipe } from '../../pipes/has-feature.pipe';
import { ExternalNavigationService } from '../../services/external-navigation.service';

@Component({
  selector: 'cog-page-footer',

  imports: [
    CommonModule,
    RouterLink,
    Footer,
    FooterMenu,
    FooterMenuItem,
    LegalLinks,
    LegalLink,
    SnsItems,
    SnsItem,
    Copyright,
    HasFeaturePipe,
  ],
  templateUrl: './page-footer.component.html',
  styleUrl: './page-footer.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PageFooterComponent {
  protected readonly config = inject(HAGURUMA_CONFIG);
  protected readonly features = this.config.features;
  protected readonly copyright = this.config.copyright;

  private readonly navigation = inject(ExternalNavigationService);
  protected readonly snsLinks = Object.values(
    this.config.predefinedSNSLinks,
  ).filter((link) => link.enabled);

  openMembership(): void {
    this.navigation.openMembershipPurchasePage('membership-plan/select');
  }

  openMyPage(): void {
    this.navigation.openMyPage('mypage');
  }
}
