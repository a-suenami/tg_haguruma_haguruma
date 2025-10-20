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
    '00000000-0000-0000-0000-000000000001' => { api_identifier: 'article', display_name: '記事', icon: '📝' },
    '00000000-0000-0000-0000-000000000002' => { api_identifier: 'announcement', display_name: 'お知らせ', icon: '📢' },
    '00000000-0000-0000-0000-000000000003' => { api_identifier: 'video', display_name: '動画', icon: '🎥' },
    '00000000-0000-0000-0000-000000000010' => { api_identifier: 'terms', display_name: '利用規約', icon: '📋' },
    '00000000-0000-0000-0000-000000000011' => { api_identifier: 'privacy', display_name: 'プライバシーポリシー', icon: '🔒' },
  }.freeze

  def api_identifier
    # 仮実装: メタデータから取得、なければIDを使用
    CONTENT_TYPE_METADATA.dig(id, :api_identifier) || id.to_s
  end

  def display_name
    CONTENT_TYPE_METADATA.dig(id, :display_name) || 'コンテンツ'
  end

  def icon
    CONTENT_TYPE_METADATA.dig(id, :icon) || '📄'
  end
end
