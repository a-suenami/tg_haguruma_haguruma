import { Controller } from '@hotwired/stimulus';

/**
 * Swiper navigation controller for prev/next scroll buttons
 *
 * Usage:
 * <div class="swiper-wrapper" data-controller="swiper-navigation">
 *   <button data-swiper-navigation-target="prevButton" data-action="swiper-navigation#prev" class="swiper-nav-button prev">‹</button>
 *   <div cog-swiper-container data-swiper-navigation-target="scroller">
 *     <div class="swiper-inner">
 *       <!-- slides -->
 *     </div>
 *   </div>
 *   <button data-swiper-navigation-target="nextButton" data-action="swiper-navigation#next" class="swiper-nav-button next">›</button>
 * </div>
 */
export default class SwiperNavigationController extends Controller {
  static targets = ['scroller', 'prevButton', 'nextButton'];

  declare readonly scrollerTarget: HTMLElement;
  declare readonly prevButtonTarget: HTMLElement;
  declare readonly nextButtonTarget: HTMLElement;

  connect() {
    this.updateButtonVisibility();
    // Re-check on window resize
    window.addEventListener('resize', this.updateButtonVisibility.bind(this));
  }

  disconnect() {
    window.removeEventListener('resize', this.updateButtonVisibility.bind(this));
  }

  private updateButtonVisibility() {
    const isScrollable = this.scrollerTarget.scrollWidth > this.scrollerTarget.clientWidth;
    const display = isScrollable ? '' : 'none';
    this.prevButtonTarget.style.display = display;
    this.nextButtonTarget.style.display = display;
  }

  private get slideWidth(): number {
    const firstSlide = this.scrollerTarget.querySelector('[cog-swiper-slide]') as HTMLElement;
    if (!firstSlide) return 300;
    const inner = this.scrollerTarget.querySelector('.swiper-inner') as HTMLElement;
    const gap = inner ? parseInt(getComputedStyle(inner).gap) || 16 : 16;
    return firstSlide.offsetWidth + gap;
  }

  prev() {
    this.scrollerTarget.scrollBy({
      left: -this.slideWidth,
      behavior: 'smooth',
    });
  }

  next() {
    this.scrollerTarget.scrollBy({
      left: this.slideWidth,
      behavior: 'smooth',
    });
  }
}
