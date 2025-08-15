// Admin Area TypeScript Entry Point
import '@hotwired/turbo-rails';
import '../styles/admin_area.scss';

interface AdminAreaConfig {
  sidebarSelector: string;
  overlaySelector: string;
  mobileMenuToggleSelector: string;
}

class AdminArea {
  private config: AdminAreaConfig;
  private sidebar: HTMLElement | null;
  private overlay: HTMLElement | null;
  private mobileMenuToggle: HTMLElement | null;

  constructor(config: AdminAreaConfig) {
    this.config = config;
    this.sidebar = document.querySelector(this.config.sidebarSelector);
    this.overlay = document.querySelector(this.config.overlaySelector);
    this.mobileMenuToggle = document.querySelector(this.config.mobileMenuToggleSelector);
    
    this.init();
  }

  private init(): void {
    this.setupMobileMenu();
    this.setupNavigationHighlight();
    console.log('Admin Area initialized');
  }

  private setupMobileMenu(): void {
    if (this.mobileMenuToggle) {
      this.mobileMenuToggle.addEventListener('click', () => this.toggleMobileMenu());
    }

    if (this.overlay) {
      this.overlay.addEventListener('click', () => this.closeMobileMenu());
    }
  }

  private toggleMobileMenu(): void {
    if (this.sidebar) {
      this.sidebar.classList.toggle('active');
    }
    if (this.overlay) {
      this.overlay.classList.toggle('active');
    }
  }

  private closeMobileMenu(): void {
    if (this.sidebar) {
      this.sidebar.classList.remove('active');
    }
    if (this.overlay) {
      this.overlay.classList.remove('active');
    }
  }

  private setupNavigationHighlight(): void {
    const currentPath = window.location.pathname;
    const navLinks = document.querySelectorAll('.sidebar-nav a');
    
    navLinks.forEach((link) => {
      const href = link.getAttribute('href');
      if (href && currentPath.includes(href)) {
        link.closest('li')?.classList.add('active');
      }
    });
  }
}

// Initialize on DOMContentLoaded
document.addEventListener('DOMContentLoaded', () => {
  new AdminArea({
    sidebarSelector: '.sidebar',
    overlaySelector: '.sidebar-overlay',
    mobileMenuToggleSelector: '.mobile-menu-toggle'
  });
});

// Re-initialize on Turbo navigation
document.addEventListener('turbo:load', () => {
  new AdminArea({
    sidebarSelector: '.sidebar',
    overlaySelector: '.sidebar-overlay',
    mobileMenuToggleSelector: '.mobile-menu-toggle'
  });
});

// Export for global access if needed
declare global {
  interface Window {
    toggleMobileMenu?: () => void;
  }
}

window.toggleMobileMenu = function() {
  const sidebar = document.querySelector('.sidebar');
  const overlay = document.querySelector('.sidebar-overlay');
  
  sidebar?.classList.toggle('active');
  overlay?.classList.toggle('active');
};