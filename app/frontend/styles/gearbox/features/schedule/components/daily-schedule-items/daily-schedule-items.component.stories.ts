import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { DailyScheduleItemComponent } from '../daily-schedule-item/daily-schedule-item.component';
import { DummyScheduleItem } from '../monthly-schedule-list/dummy-schedule-items';
import { DailyScheduleItemsComponent } from './daily-schedule-items.component';

const meta: Meta<DailyScheduleItemsComponent> = {
  title: 'Features/Schedule/Components/DailyScheduleItems',
  component: DailyScheduleItemsComponent,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [DailyScheduleItemsComponent, DailyScheduleItemComponent],
    }),
  ],
  parameters: {
    layout: 'padded',
  },
};

export default meta;
type Story = StoryObj<DailyScheduleItemsComponent>;

export const Default: Story = {
  render: () => {
    const scheduleItems: DummyScheduleItem[] = [
      {
        date: '2025-07-01',
        category: 'LIVE',
        title: 'CANDY CARNIVAL TOUR 2025 - 東京ドーム',
      },
      {
        date: '2025-07-03',
        category: 'TV',
        title: 'ミュージックステーション出演「新曲初披露」',
      },
      {
        date: '2025-07-05',
        category: 'RADIO',
        title: 'きゃりーぱみゅぱみゅのウェイウェイレディオ',
      },
      {
        date: '2025-07-08',
        category: 'EVENT',
        title: 'ファッションウィーク2025 スペシャルゲスト',
      },
      {
        date: '2025-07-10',
        category: 'OTHER',
        title: '新アルバム「CANDY UNIVERSE」リリース記念イベント',
      },
    ];

    return {
      props: { scheduleItems },
      template: `
        <cog-daily-schedule-items>
        @for (item of scheduleItems; track item.date) {
          <cog-daily-schedule-item  [schedule]="item"></cog-daily-schedule-item>
        }
        </cog-daily-schedule-items>
      `,
    };
  },
};
