import { Controller } from '@hotwired/stimulus';

/**
 * Swiper pagination controller with dot indicators
 *
 * Usage:
 * <div class="swiper-pagination-wrapper" data-controller="swiper-pagination">
 *   <div cog-swiper-container data-swiper-pagination-target="scroller">
 *     <div class="swiper-inner">
 *       <!-- slides with cog-swiper-slide attribute -->
 *     </div>
 *   </div>
 *   <div class="swiper-dots" data-swiper-pagination-target="dots"></div>
 * </div>
 */
export default class SwiperPaginationController extends Controller {
  static targets = ['scroller', 'dots'];

  declare readonly scrollerTarget: HTMLElement;
  declare readonly dotsTarget: HTMLElement;

  private currentIndex: number = 0;
  private slideCount: number = 0;

  connect() {
    this.initializeDots();
    this.scrollerTarget.addEventListener('scroll', this.handleScroll.bind(this));
    window.addEventListener('resize', this.handleResize.bind(this));
  }

  disconnect() {
    this.scrollerTarget.removeEventListener('scroll', this.handleScroll.bind(this));
    window.removeEventListener('resize', this.handleResize.bind(this));
  }

  private initializeDots() {
    const slides = this.scrollerTarget.querySelectorAll('[cog-swiper-slide]');
    this.slideCount = slides.length;

    if (this.slideCount <= 1) {
      this.dotsTarget.style.display = 'none';
      return;
    }

    this.dotsTarget.innerHTML = '';
    for (let i = 0; i < this.slideCount; i++) {
      const dot = document.createElement('button');
      dot.type = 'button';
      dot.className = 'swiper-dot';
      dot.setAttribute('aria-label', `スライド ${i + 1}`);
      dot.dataset.index = String(i);
      if (i === 0) dot.classList.add('active');
      dot.addEventListener('click', () => this.goToSlide(i));
      this.dotsTarget.appendChild(dot);
    }
  }

  private handleScroll() {
    const slides = Array.from(this.scrollerTarget.querySelectorAll('[cog-swiper-slide]')) as HTMLElement[];
    if (slides.length === 0) return;

    const scrollLeft = this.scrollerTarget.scrollLeft;
    const containerWidth = this.scrollerTarget.clientWidth;
    const containerCenter = scrollLeft + containerWidth / 2;

    let closestIndex = 0;
    let closestDistance = Infinity;

    slides.forEach((slide, index) => {
      const slideCenter = slide.offsetLeft + slide.offsetWidth / 2;
      const distance = Math.abs(containerCenter - slideCenter);
      if (distance < closestDistance) {
        closestDistance = distance;
        closestIndex = index;
      }
    });

    if (closestIndex !== this.currentIndex) {
      this.currentIndex = closestIndex;
      this.updateActiveDot();
    }
  }

  private handleResize() {
    this.handleScroll();
  }

  private updateActiveDot() {
    const dots = this.dotsTarget.querySelectorAll('.swiper-dot');
    dots.forEach((dot, index) => {
      dot.classList.toggle('active', index === this.currentIndex);
    });
  }

  private goToSlide(index: number) {
    const slides = Array.from(this.scrollerTarget.querySelectorAll('[cog-swiper-slide]')) as HTMLElement[];
    if (index < 0 || index >= slides.length) return;

    const targetSlide = slides[index];
    const containerWidth = this.scrollerTarget.clientWidth;
    const slideCenter = targetSlide.offsetLeft + targetSlide.offsetWidth / 2;
    const scrollTo = slideCenter - containerWidth / 2;

    this.scrollerTarget.scrollTo({
      left: scrollTo,
      behavior: 'smooth',
    });
  }
}
