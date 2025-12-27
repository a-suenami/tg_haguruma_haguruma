import { InjectionToken, Provider } from '@angular/core';

export type OptionalFeatureName =
  | 'news'
  | 'schedule'
  | 'blog'
  | 'video'
  | 'ticket';

export type HagurumaFeatureName = OptionalFeatureName | 'mypage';

export interface HagurumaFeatureEntry<
  TName extends HagurumaFeatureName = HagurumaFeatureName,
> {
  name: TName;
  label: string;
  enabled: boolean;
}

export type HagurumaFeatures = Record<
  OptionalFeatureName,
  HagurumaFeatureEntry<OptionalFeatureName>
> & {
  readonly mypage: HagurumaFeatureEntry<'mypage'> & { enabled: true };
};

export type PredefinedSNSName = 'line' | 'instagram' | 'x' | 'youtube';

export interface PredefinedSNSLinkEntry {
  readonly name: PredefinedSNSName;
  readonly link: string;
  readonly enabled: boolean;
}

export type PredefinedSNSLinks = Record<
  PredefinedSNSName,
  PredefinedSNSLinkEntry
>;

export interface HagurumaConfig {
  readonly copyright: string;
  readonly urls: {
    readonly authentication: string;
    readonly membership: string;
    readonly mypage: string;
  };
  readonly features: HagurumaFeatures;
  readonly predefinedSNSLinks: PredefinedSNSLinks;
}

export const HAGURUMA_CONFIG = new InjectionToken<HagurumaConfig>(
  'HAGURUMA_CONFIG',
);

export const provideHagurumaConfig = (config: HagurumaConfig): Provider => ({
  provide: HAGURUMA_CONFIG,
  useValue: config,
});
