import { DOCUMENT } from '@angular/common';
import { inject, Injectable } from '@angular/core';

import { HAGURUMA_CONFIG } from '../config/haguruma-config.token';

export type NavigationTarget = '_self' | '_blank';

export type AuthenticationPath = 'auth/sign_in' | 'auth/register';
export type MembershipPath = 'membership-plan/select';
export type MyPagePath = 'mypage';

@Injectable({
  providedIn: 'root',
})
export class ExternalNavigationService {
  private readonly config = inject(HAGURUMA_CONFIG);
  private readonly document = inject(DOCUMENT);

  openAuthenticationPage(
    path: AuthenticationPath,
    target: NavigationTarget = '_blank',
  ): void {
    const url = this.composeUrl(this.config.urls.authentication, path);
    this.openExternal(url, target);
  }

  openMembershipPurchasePage(
    path: MembershipPath,
    target: NavigationTarget = '_blank',
  ): void {
    const url = this.composeUrl(this.config.urls.membership, path);
    this.openExternal(url, target);
  }

  openMyPage(path: MyPagePath, target: NavigationTarget = '_blank'): void {
    const url = this.composeUrl(this.config.urls.mypage, path);
    this.openExternal(url, target);
  }

  private composeUrl(base: string, path: string): string {
    const normalizedBase = base.endsWith('/') ? base.slice(0, -1) : base;
    const normalizedPath = path.startsWith('/') ? path.slice(1) : path;

    return `${normalizedBase}/${normalizedPath}`;
  }

  private openExternal(url: string, target: NavigationTarget): void {
    const defaultView = this.document.defaultView;
    if (!defaultView || target === '_self') {
      this.document.location.href = url;
      return;
    }

    defaultView.open(url, target, 'noopener');
  }
}
