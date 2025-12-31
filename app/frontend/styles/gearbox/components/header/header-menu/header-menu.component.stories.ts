import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { HeaderMenuItem } from '../header-menu-item/header-menu-item.component';
import { HeaderMenu } from './header-menu.component';

const meta: Meta<HeaderMenu> = {
  component: HeaderMenu,
  title: 'Core/Components/Header/HeaderMenu',
  decorators: [
    moduleMetadata({
      imports: [HeaderMenuItem],
    }),
  ],
};
export default meta;

type Story = StoryObj<HeaderMenu>;

export const Default: Story = {
  render: () => ({
    imports: [HeaderMenuItem],
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <cog-header-menu>
          <a href="/home" cog-header-menu-item class="active">Home</a>
          <a href="/about" cog-header-menu-item>About</a>
          <a href="/services" cog-header-menu-item>Services</a>
          <a href="/contact" cog-header-menu-item>Contact</a>
        </cog-header-menu>
      </div>
    `,
  }),
};

export const FewItems: Story = {
  render: () => ({
    imports: [HeaderMenuItem],
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <cog-header-menu>
          <a href="/home" cog-header-menu-item class="active">Home</a>
          <a href="/about" cog-header-menu-item>About</a>
        </cog-header-menu>
      </div>
    `,
  }),
};

export const ManyItems: Story = {
  render: () => ({
    imports: [HeaderMenuItem],
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <cog-header-menu>
          <a href="/home" cog-header-menu-item class="active">Home</a>
          <a href="/products" cog-header-menu-item>Products</a>
          <a href="/services" cog-header-menu-item>Services</a>
          <a href="/about" cog-header-menu-item>About</a>
          <a href="/blog" cog-header-menu-item>Blog</a>
          <a href="/careers" cog-header-menu-item>Careers</a>
          <a href="/contact" cog-header-menu-item>Contact</a>
        </cog-header-menu>
      </div>
    `,
  }),
};

export const MixedLanguages: Story = {
  render: () => ({
    imports: [HeaderMenuItem],
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <cog-header-menu>
          <a href="/home" cog-header-menu-item class="active">ホーム</a>
          <a href="/about" cog-header-menu-item>About</a>
          <a href="/services" cog-header-menu-item>サービス</a>
          <a href="/contact" cog-header-menu-item>Contact</a>
        </cog-header-menu>
      </div>
    `,
  }),
};

export const ResponsiveBehavior: Story = {
  render: () => ({
    imports: [HeaderMenuItem],
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <div style="border: 1px dashed #ccc; padding: 1rem; margin-bottom: 2rem;">
          <p style="margin-bottom: 1rem;">Desktop view (resize window to see mobile behavior):</p>
          <cog-header-menu>
            <a href="/home" cog-header-menu-item class="active">Home</a>
            <a href="/about" cog-header-menu-item>About</a>
            <a href="/services" cog-header-menu-item>Services</a>
            <a href="/contact" cog-header-menu-item>Contact</a>
          </cog-header-menu>
        </div>
        <div style="max-width: 768px; border: 1px dashed #ccc; padding: 1rem;">
          <p style="margin-bottom: 1rem;">Mobile view simulation:</p>
          <cog-header-menu>
            <a href="/home" cog-header-menu-item class="active">Home</a>
            <a href="/about" cog-header-menu-item>About</a>
            <a href="/services" cog-header-menu-item>Services</a>
            <a href="/contact" cog-header-menu-item>Contact</a>
          </cog-header-menu>
        </div>
      </div>
    `,
  }),
};
