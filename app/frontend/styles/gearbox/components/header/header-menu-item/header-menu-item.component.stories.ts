import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { HeaderMenuItem } from './header-menu-item.component';

const meta: Meta<HeaderMenuItem> = {
  component: HeaderMenuItem,
  title: 'Core/Components/Header/HeaderMenuItem',
  decorators: [
    moduleMetadata({
      imports: [],
    }),
  ],
};
export default meta;

type Story = StoryObj<HeaderMenuItem>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <a href="/home" cog-header-menu-item>
          Home
        </a>
      </div>
    `,
  }),
};

export const Active: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <a href="/about" cog-header-menu-item class="active">
          About
        </a>
      </div>
    `,
  }),
};

export const NavigationExample: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <nav style="display: flex; gap: 2rem;">
          <a href="/home" cog-header-menu-item class="active">
            Home
          </a>
          <a href="/about" cog-header-menu-item>
            About
          </a>
          <a href="/services" cog-header-menu-item>
            Services
          </a>
          <a href="/contact" cog-header-menu-item>
            Contact
          </a>
        </nav>
      </div>
    `,
  }),
};

export const RouterLinkActiveExample: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <h3 style="margin-bottom: 1rem; color: #666;">With routerLinkActive (simulated)</h3>
        <nav style="display: flex; gap: 2rem;">
          <!-- In real usage with Angular Router: -->
          <!-- <a routerLink="/home" routerLinkActive="active" cog-header-menu-item>Home</a> -->

          <!-- Simulated for Storybook: -->
          <a href="/home" cog-header-menu-item>
            Home
          </a>
          <a href="/about" cog-header-menu-item class="active">
            About (Current Page)
          </a>
          <a href="/services" cog-header-menu-item>
            Services
          </a>
        </nav>
        <div style="margin-top: 2rem; padding: 1rem; background-color: rgba(0,0,0,0.05); border-radius: 4px;">
          <code style="font-size: 12px;">
            In Angular templates, use: &lt;a routerLink="/path" routerLinkActive="active" cog-header-menu-item&gt;Link&lt;/a&gt;
          </code>
        </div>
      </div>
    `,
  }),
};
