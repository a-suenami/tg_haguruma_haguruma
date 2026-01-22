import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';
import { INITIAL_VIEWPORTS } from 'storybook/viewport';

import { Copyright } from '../../copyright/copyright/copyright.component';
import { LegalLink } from '../../legal/legal-link/legal-link.component';
import { LegalLinks } from '../../legal/legal-links/legal-links.component';
import { SnsItem } from '../../social/sns-item/sns-item.component';
import { SnsItems } from '../../social/sns-items/sns-items.component';
import { FooterMenuItem } from '../footer-menu-item/footer-menu-item.component';
import { FooterMenu } from '../footer-menu/footer-menu.component';
import { Footer } from './footer.component';

const meta: Meta<Footer> = {
  component: Footer,
  title: 'Core/Components/Footer/Footer',
  decorators: [
    moduleMetadata({
      imports: [
        FooterMenu,
        FooterMenuItem,
        LegalLinks,
        LegalLink,
        SnsItems,
        SnsItem,
        Copyright,
      ],
    }),
  ],
  parameters: {
    layout: 'fullscreen',
    viewport: {
      viewports: INITIAL_VIEWPORTS,
    },
  },
};
export default meta;

type Story = StoryObj<Footer>;

const template = `
   <footer cog-footer>
    <cog-footer-menu>
      <a cog-footer-menu-item>TOP</a>
      <a cog-footer-menu-item>NEWS</a>
      <a cog-footer-menu-item>TICKET</a>
      <a cog-footer-menu-item>BLOG</a>
      <a cog-footer-menu-item>SCHEDULE</a>
      <a cog-footer-menu-item>MY PAGE</a>
    </cog-footer-menu>

    <cog-legal-links>
      <a cog-legal-link>利用規約・チケット規約</a>
      <a cog-legal-link>個人情報の取り扱いについて</a>
      <a cog-legal-link>サイトポリシー</a>
      <a cog-legal-link>特定商取引法に基づく表記</a>
      <a cog-legal-link>FAQ / お問い合わせ</a>
    </cog-legal-links>

    <cog-sns-items>
      <a cog-sns-item [type]="'line'" href="https://line.me/example" target="_blank"></a>
      <a cog-sns-item [type]="'x'" href="https://x.com/example" target="_blank"></a>
      <a cog-sns-item [type]="'instagram'" href="https://instagram.com/example" target="_blank"></a>
      <a cog-sns-item [type]="'youtube'" href="https://youtube.com/@example" target="_blank"></a>
    </cog-sns-items>

    <cog-copyright>&copy; 2025 Gearbox. All rights reserved.</cog-copyright>
  </footer>
`;

export const Browser: Story = {
  args: {},
  parameters: {
    viewport: {
      defaultViewport: 'responsive',
    },
  },
  render: () => ({ template }),
};

export const Mobile: Story = {
  args: {},
  parameters: {
    viewport: {
      value: 'mobile1',
      isRotated: false,
    },
  },
  render: () => ({ template }),
};

export const Tablet: Story = {
  args: {},
  parameters: {
    viewport: {
      value: 'tablet',
      isRotated: false,
    },
  },
  render: () => ({ template }),
};
