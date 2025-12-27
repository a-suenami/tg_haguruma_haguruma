export interface DummyBlogOverview {
  title: string;
  date: string;
  category: {
    label: string;
    type: 'fashion' | 'lifestyle' | 'travel' | 'food' | 'music';
  };
  author: string;
  excerpt: string;
}

export const dummyBlogItems: DummyBlogOverview[] = [
  {
    title: '新しいMVの衣装がカワイイすぎる件について💖',
    date: '2024-12-20',
    category: {
      label: 'ファッション',
      type: 'fashion',
    },
    author: 'きゃりーぱみゅぱみゅ',
    excerpt: '今回のMV撮影で着た衣装がめちゃくちゃお気に入り！ピンクとパープルのグラデーションに、キラキラのラインストーンがいっぱい...',
  },
  {
    title: 'ロサンゼルスで見つけたカワイイカフェ巡り🍰',
    date: '2024-12-18',
    category: {
      label: '旅行',
      type: 'travel',
    },
    author: 'きゃりーぱみゅぱみゅ',
    excerpt: 'LAツアーの合間に行ったカフェが全部カワイすぎた！ユニコーンラテとレインボーケーキの写真もいっぱい撮ったよ〜...',
  },
  {
    title: '原宿で買ったお気に入りアクセサリー特集✨',
    date: '2024-12-15',
    category: {
      label: 'ファッション',
      type: 'fashion',
    },
    author: 'きゃりーぱみゅぱみゅ',
    excerpt: '竹下通りで見つけたカラフルなヘアピンとか、きらきらのイヤリングとか、全部カワイすぎて困っちゃう...',
  },
  {
    title: '新曲のレコーディング裏話🎵',
    date: '2024-12-12',
    category: {
      label: '音楽',
      type: 'music',
    },
    author: 'きゃりーぱみゅぱみゅ',
    excerpt: 'スタジオで朝まで歌ってた！中田ヤスタカさんと一緒に作った新しい曲、みんなに早く聴いてもらいたいな〜...',
  },
  {
    title: 'お家で作るカラフルパフェレシピ🍨',
    date: '2024-12-10',
    category: {
      label: '料理',
      type: 'food',
    },
    author: 'きゃりーぱみゅぱみゅ',
    excerpt: '見た目もカワイくて美味しいパフェの作り方！ピンクのアイスにカラフルなトッピングをいっぱいのせて...',
  },
  {
    title: 'ライブのリハーサル風景をちょっとだけ公開💫',
    date: '2024-12-08',
    category: {
      label: 'ライフスタイル',
      type: 'lifestyle',
    },
    author: 'きゃりーぱみゅぱみゅ',
    excerpt: 'ダンサーのみんなと一緒に新しい振り付けを練習中！今回のツアーもカラフルでポップな演出がいっぱいだよ...',
  },
  {
    title: 'パリで出会った不思議なファッション👗',
    date: '2024-12-05',
    category: {
      label: '旅行',
      type: 'travel',
    },
    author: 'きゃりーぱみゅぱみゅ',
    excerpt: 'パリコレで見たファッションがすごすぎた！日本のカワイイ文化とフランスのエレガントが混ざってて...',
  },
  {
    title: 'お気に入りのネイルデザイン集💅',
    date: '2024-12-03',
    category: {
      label: 'ファッション',
      type: 'fashion',
    },
    author: 'きゃりーぱみゅぱみゅ',
    excerpt: '今月やったネイル全部見せます！3Dのリボンとか、ホログラムとか、キャラクターネイルとか盛りだくさん...',
  },
];