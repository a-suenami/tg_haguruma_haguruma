# typed: false

class ContentType < ApplicationRecord
  has_many :fields, dependent: :destroy
  has_many :content_entries, dependent: :destroy

  validates :tenant_id, presence: true
  validates :is_collection, inclusion: { in: [true, false] }

  # マルチテナント対応
  default_scope { where(tenant_id: Tenant.current_id) if Tenant.current_id.present? }

  scope :collections, -> { where(is_collection: true) }
  scope :singles, -> { where(is_collection: false) }

  # 一時的な表示用メソッド（後でDBカラムに移行予定）
  # TODO: display_name, api_identifier, icon カラムをスキーマに追加後、これらのメソッドを削除
  CONTENT_TYPE_METADATA = {
    'article' => { display_name: '記事', icon: '📝' },
    'announcement' => { display_name: 'お知らせ', icon: '📢' },
    'product' => { display_name: '商品', icon: '🛍️' },
    'profile' => { display_name: 'プロフィール', icon: '👤' },
    'gallery' => { display_name: 'ギャラリー', icon: '📸' },
    'about' => { display_name: '会社概要', icon: '📄' },
    'privacy' => { display_name: 'プライバシーポリシー', icon: '🔒' },
    'terms' => { display_name: '利用規約', icon: '📋' },
    'contact' => { display_name: 'お問い合わせ', icon: '📮' },
    'settings' => { display_name: 'サイト設定', icon: '⚙️' },
  }.freeze

  def api_identifier
    # 仮実装: IDをそのまま使用（後でDBカラムから取得）
    id.to_s
  end

  def display_name
    CONTENT_TYPE_METADATA.dig(api_identifier, :display_name) || 'コンテンツ'
  end

  def icon
    CONTENT_TYPE_METADATA.dig(api_identifier, :icon) || '📄'
  end
end
