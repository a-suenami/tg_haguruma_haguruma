import { Controller } from '@hotwired/stimulus';

/**
 * Category tabs controller for managing active state without full page reload
 * When using Turbo Frames, the tabs don't re-render, so we need to update
 * the active state client-side when a tab is clicked.
 *
 * Usage:
 * <nav data-controller="category-tabs" cog-tabs-bar>
 *   <div cog-tabs>
 *     <a data-category-tabs-target="tab" data-action="click->category-tabs#select" ...>
 *       <div class="text">All</div>
 *     </a>
 *     <a data-category-tabs-target="tab" data-action="click->category-tabs#select" ...>
 *       <div class="text">Category 1</div>
 *     </a>
 *   </div>
 * </nav>
 */
export default class CategoryTabsController extends Controller {
  static targets = ['tab'];

  declare readonly tabTargets: HTMLAnchorElement[];

  connect() {
    // Sync active state with URL on connect (for browser back/forward)
    this.syncActiveState();

    // Listen for Turbo frame loads to sync active state
    document.addEventListener('turbo:frame-load', this.handleFrameLoad);
  }

  disconnect() {
    document.removeEventListener('turbo:frame-load', this.handleFrameLoad);
  }

  select(event: Event) {
    const clickedTab = event.currentTarget as HTMLAnchorElement;

    // Update active state immediately for better UX
    this.tabTargets.forEach((tab) => {
      tab.classList.remove('active');
    });
    clickedTab.classList.add('active');
  }

  private handleFrameLoad = () => {
    // Sync active state when Turbo frame is loaded (e.g., browser back/forward)
    this.syncActiveState();
  };

  private syncActiveState() {
    const currentPath = window.location.pathname;
    const currentSearch = window.location.search;
    const currentUrl = currentPath + currentSearch;

    this.tabTargets.forEach((tab) => {
      const tabUrl = new URL(tab.href, window.location.origin);
      const tabPath = tabUrl.pathname + tabUrl.search;

      if (tabPath === currentUrl) {
        tab.classList.add('active');
      } else {
        tab.classList.remove('active');
      }
    });
  }
}
