// Ruler Area TypeScript Entry Point
import '@hotwired/turbo-rails';
import '../styles/ruler_area.scss';

interface RulerAreaConfig {
  tableSelector: string;
  searchInputSelector: string;
  filterSelectSelector: string;
}

class RulerArea {
  private config: RulerAreaConfig;
  private tables: NodeListOf<HTMLTableElement>;
  private searchInputs: NodeListOf<HTMLInputElement>;
  private filterSelects: NodeListOf<HTMLSelectElement>;

  constructor(config: RulerAreaConfig) {
    this.config = config;
    this.tables = document.querySelectorAll(this.config.tableSelector);
    this.searchInputs = document.querySelectorAll(this.config.searchInputSelector);
    this.filterSelects = document.querySelectorAll(this.config.filterSelectSelector);
    
    this.init();
  }

  private init(): void {
    this.setupTableInteractions();
    this.setupSearch();
    this.setupFilters();
    console.log('Ruler Area initialized');
  }

  private setupTableInteractions(): void {
    this.tables.forEach((table) => {
      // Add hover effects to table rows
      const rows = table.querySelectorAll('tbody tr');
      rows.forEach((row) => {
        row.addEventListener('mouseenter', () => {
          row.classList.add('hover');
        });
        row.addEventListener('mouseleave', () => {
          row.classList.remove('hover');
        });
      });

      // Make rows clickable if they have data-href
      const clickableRows = table.querySelectorAll('tbody tr[data-href]');
      clickableRows.forEach((row) => {
        row.style.cursor = 'pointer';
        row.addEventListener('click', (e) => {
          const target = e.target as HTMLElement;
          // Don't navigate if clicking on a link or button
          if (!target.closest('a') && !target.closest('button')) {
            const href = row.getAttribute('data-href');
            if (href) {
              window.location.href = href;
            }
          }
        });
      });
    });
  }

  private setupSearch(): void {
    this.searchInputs.forEach((input) => {
      let debounceTimer: NodeJS.Timeout;
      
      input.addEventListener('input', (e) => {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(() => {
          this.performSearch((e.target as HTMLInputElement).value);
        }, 300);
      });
    });
  }

  private performSearch(query: string): void {
    // This would typically make an AJAX request to the server
    console.log(`Searching for: ${query}`);
    // For now, just filter the table client-side
    this.tables.forEach((table) => {
      const rows = table.querySelectorAll('tbody tr');
      rows.forEach((row) => {
        const text = row.textContent?.toLowerCase() || '';
        const searchTerm = query.toLowerCase();
        if (text.includes(searchTerm)) {
          (row as HTMLElement).style.display = '';
        } else {
          (row as HTMLElement).style.display = 'none';
        }
      });
    });
  }

  private setupFilters(): void {
    this.filterSelects.forEach((select) => {
      select.addEventListener('change', (e) => {
        const value = (e.target as HTMLSelectElement).value;
        this.applyFilter(value);
      });
    });
  }

  private applyFilter(filterValue: string): void {
    // This would typically make an AJAX request to the server
    console.log(`Applying filter: ${filterValue}`);
    // Implementation would depend on specific filter requirements
  }

  public refreshData(): void {
    // Method to refresh data via AJAX
    console.log('Refreshing ruler area data...');
  }
}

// Initialize on DOMContentLoaded
document.addEventListener('DOMContentLoaded', () => {
  new RulerArea({
    tableSelector: '.table',
    searchInputSelector: '.search-input',
    filterSelectSelector: '.filter-select'
  });
});

// Re-initialize on Turbo navigation
document.addEventListener('turbo:load', () => {
  new RulerArea({
    tableSelector: '.table',
    searchInputSelector: '.search-input',
    filterSelectSelector: '.filter-select'
  });
});

export default RulerArea;