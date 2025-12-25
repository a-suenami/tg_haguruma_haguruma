import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { HeaderMenuOverlayFooterComponent } from './header-menu-overlay-footer.component';

const meta: Meta<HeaderMenuOverlayFooterComponent> = {
  component: HeaderMenuOverlayFooterComponent,
  title: 'Core/Components/Header/HeaderMenuOverlayFooter',
  decorators: [
    moduleMetadata({
      imports: [],
    }),
  ],
};
export default meta;

type Story = StoryObj<HeaderMenuOverlayFooterComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <cog-header-menu-overlay-footer>
          Header Menu Overlay Footer Content
        </cog-header-menu-overlay-footer>
      </div>
    `,
  }),
};
