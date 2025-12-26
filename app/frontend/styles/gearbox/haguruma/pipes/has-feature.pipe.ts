import { Pipe, PipeTransform } from '@angular/core';

import {
  HagurumaConfig,
  HagurumaFeatureEntry,
  OptionalFeatureName,
} from '../config/haguruma-config.token';

@Pipe({
  name: 'hagurumaHasFeature',
  standalone: true,
})
export class HasFeaturePipe implements PipeTransform {
  transform(
    features: HagurumaConfig['features'],
    feature: OptionalFeatureName,
  ): HagurumaFeatureEntry | null {
    const entry = features?.[feature];
    return entry?.enabled ? entry : null;
  }
}
