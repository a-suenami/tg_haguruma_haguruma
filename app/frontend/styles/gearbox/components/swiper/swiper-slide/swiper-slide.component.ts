import {
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  Component,
  CUSTOM_ELEMENTS_SCHEMA,
  ElementRef,
  inject,
  NgZone,
} from '@angular/core';
import { SwiperSlide as SwiperSlideElement } from 'swiper/element';

@Component({
  selector: 'swiper-slide',
  imports: [],
  template: '<ng-content></ng-content>',
  styleUrl: './swiper-slide.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  schemas: [CUSTOM_ELEMENTS_SCHEMA],
})
export class SwiperSlide {
  private readonly changeDetectorRef = inject(ChangeDetectorRef);
  private readonly elementRef =
    inject<ElementRef<SwiperSlideElement>>(ElementRef);
  protected readonly ngZone = inject(NgZone);

  protected slideElement: SwiperSlideElement;

  constructor() {
    this.changeDetectorRef.detach();
    this.slideElement = this.elementRef.nativeElement as SwiperSlideElement;
  }
}
