import { Controller } from '@hotwired/stimulus';
import Swiper from 'swiper';
import { Navigation, Pagination } from 'swiper/modules';
import 'swiper/css';
import 'swiper/css/pagination';

/**
 * Swiper controller using swiper.js library
 *
 * Usage:
 * <div class="swiper" data-controller="swiper">
 *   <div class="swiper-wrapper">
 *     <div class="swiper-slide">Slide 1</div>
 *     <div class="swiper-slide">Slide 2</div>
 *   </div>
 *   <div class="swiper-pagination"></div>
 *   <div class="swiper-button-prev"></div>
 *   <div class="swiper-button-next"></div>
 * </div>
 *
 * Data attributes:
 * - data-swiper-slides-per-view-value: Number of slides per view (default: "auto")
 * - data-swiper-space-between-value: Space between slides in px (default: 16)
 * - data-swiper-loop-value: Enable loop mode (default: false)
 * - data-swiper-autoplay-value: Enable autoplay with delay in ms (default: 0 = disabled)
 */
export default class SwiperController extends Controller {
  static values = {
    slidesPerView: { type: String, default: 'auto' },
    spaceBetween: { type: Number, default: 16 },
    loop: { type: Boolean, default: false },
    autoplay: { type: Number, default: 0 },
  };

  declare slidesPerViewValue: string;
  declare spaceBetweenValue: number;
  declare loopValue: boolean;
  declare autoplayValue: number;

  private swiper: Swiper | null = null;

  connect() {
    this.initSwiper();
  }

  disconnect() {
    if (this.swiper) {
      this.swiper.destroy(true, true);
      this.swiper = null;
    }
  }

  private initSwiper() {
    const slidesPerView = this.slidesPerViewValue === 'auto'
      ? 'auto'
      : parseInt(this.slidesPerViewValue, 10);

    this.swiper = new Swiper(this.element as HTMLElement, {
      modules: [Navigation, Pagination],
      slidesPerView,
      spaceBetween: this.spaceBetweenValue,
      loop: this.loopValue,
      watchOverflow: true,
      pagination: {
        el: this.element.querySelector('.swiper-pagination') as HTMLElement | null,
        clickable: true,
      },
      navigation: {
        nextEl: this.element.querySelector('.swiper-button-next') as HTMLElement | null,
        prevEl: this.element.querySelector('.swiper-button-prev') as HTMLElement | null,
      },
    });
  }
}
