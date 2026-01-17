import { Controller } from '@hotwired/stimulus';
import Swiper from 'swiper';
import { Pagination } from 'swiper/modules';
import 'swiper/css';
import 'swiper/css/pagination';

/**
 * Swiper controller using swiper.js library
 *
 * Behavior:
 * - When all slides fit within container: pagination hidden, slides centered
 * - When slides overflow: pagination shown, active slide centered
 * - Dynamically switches on window resize
 *
 * Usage:
 * <div class="swiper" data-controller="swiper">
 *   <div class="swiper-wrapper">
 *     <div class="swiper-slide">Slide 1</div>
 *     <div class="swiper-slide">Slide 2</div>
 *   </div>
 *   <div class="swiper-pagination"></div>
 * </div>
 *
 * Data attributes:
 * - data-swiper-slides-per-view-value: Number of slides per view (default: "auto")
 * - data-swiper-space-between-value: Space between slides in px (default: 16)
 */
export default class SwiperController extends Controller {
  static values = {
    slidesPerView: { type: String, default: 'auto' },
    spaceBetween: { type: Number, default: 16 },
  };

  declare slidesPerViewValue: string;
  declare spaceBetweenValue: number;

  private swiper: Swiper | null = null;
  private resizeObserver: ResizeObserver | null = null;

  connect() {
    this.initSwiper();
    this.setupResizeObserver();
    requestAnimationFrame(() => this.updateDisplayMode());
  }

  disconnect() {
    this.resizeObserver?.disconnect();
    this.resizeObserver = null;
    this.swiper?.destroy(true, true);
    this.swiper = null;
  }

  private initSwiper() {
    const slidesPerView = this.slidesPerViewValue === 'auto' ? 'auto' : parseInt(this.slidesPerViewValue, 10);

    this.swiper = new Swiper(this.element as HTMLElement, {
      modules: [Pagination],
      slidesPerView,
      spaceBetween: this.spaceBetweenValue,
      centeredSlides: true,
      pagination: {
        el: this.element.querySelector('.swiper-pagination') as HTMLElement | null,
        clickable: true,
      },
    });
  }

  private setupResizeObserver() {
    this.resizeObserver = new ResizeObserver(() => {
      this.updateDisplayMode();
    });
    this.resizeObserver.observe(this.element);
  }

  private checkIfFits(): boolean {
    const slides = this.element.querySelectorAll('.swiper-slide');
    const containerWidth = (this.element as HTMLElement).clientWidth;
    let totalWidth = 0;

    slides.forEach((slide, i) => {
      totalWidth += (slide as HTMLElement).offsetWidth;
      if (i < slides.length - 1) {
        totalWidth += this.spaceBetweenValue;
      }
    });

    return totalWidth <= containerWidth;
  }

  private updateDisplayMode() {
    const fits = this.checkIfFits();
    const pagination = this.element.querySelector('.swiper-pagination') as HTMLElement | null;

    if (fits) {
      this.swiper?.disable();
      this.element.classList.add('swiper--fits');
      if (pagination) pagination.style.display = 'none';
    } else {
      this.swiper?.enable();
      this.element.classList.remove('swiper--fits');
      if (pagination) pagination.style.display = '';
    }
  }
}
