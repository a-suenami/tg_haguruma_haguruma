export interface DummyNewsOverview {
  title: string;
  date: string;
  category: {
    label: string;
    type: 'updates';
  }
}


export const dummyNewsItems = Array(10).fill(0).map((_, index) => ({
  title: `News ${index + 1}`,
  date: `2021-01-01`,
  category: {
    label: '更新履歴',
    type: 'updates',
  },
} as DummyNewsOverview));
