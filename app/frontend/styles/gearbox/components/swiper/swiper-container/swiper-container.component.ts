import {
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  Component,
  CUSTOM_ELEMENTS_SCHEMA,
  ElementRef,
  inject,
  input,
  OnInit,
  output,
} from '@angular/core';
import { SwiperContainer as SwiperElement } from 'swiper/element';
import { SwiperOptions } from 'swiper/types';

@Component({
  selector: 'swiper-container',
  imports: [],
  schemas: [CUSTOM_ELEMENTS_SCHEMA],
  template: '<ng-content></ng-content>',
  styleUrl: './swiper-container.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    init: 'false',
  },
})
export class SwiperContainer implements OnInit {
  private readonly changeDetectorRef = inject(ChangeDetectorRef);
  private readonly elementRef = inject<ElementRef<SwiperElement>>(ElementRef);

  readonly options = input<SwiperOptions>({});
  readonly slideChange = output<number>();

  private swiperElement!: SwiperElement;

  get swiper() {
    return this.swiperElement.swiper;
  }

  constructor() {
    this.changeDetectorRef.detach();
    this.swiperElement = this.elementRef.nativeElement as SwiperElement;
  }

  ngOnInit(): void {
    const swiperOptions = this.options();

    if ('allowTouchMove' in swiperOptions) {
      this.swiper.allowTouchMove = swiperOptions.allowTouchMove ?? false;
      this.swiperElement.allowTouchMove = swiperOptions.allowTouchMove;
    }

    Object.assign(this.swiperElement, swiperOptions);

    this.swiperElement.initialize();

    this.swiper.on('slideChange', () => {
      this.slideChange.emit(this.swiper.activeIndex);
    });
  }

  update(options: SwiperOptions) {
    Object.assign(this.swiperElement, options);
    this.swiper.update();
  }
}
