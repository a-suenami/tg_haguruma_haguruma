# typed: false

# == Schema Information
#
# Table name: content_types
#
#  id            :uuid             not null, primary key
#  description   :text
#  display_name  :text
#  is_collection :boolean          default(TRUE), not null
#  unique_name   :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tenant_id     :citext           not null
#
# Indexes
#
#  index_content_types_on_id_and_tenant_id  (id,tenant_id) UNIQUE
#  index_content_types_on_tenant_id_and_id  (tenant_id,id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (tenant_id => tenants.id)
#
class ContentType < ApplicationRecord
  include Multitenancy

  has_many :fields, -> { order(:position) }, dependent: :destroy, inverse_of: :content_type
  has_many :content_entries, dependent: :destroy

  accepts_nested_attributes_for :fields, allow_destroy: true, reject_if: :all_blank

  validates :unique_name, presence: true, length: { maximum: 32 }, uniqueness: { scope: :tenant_id }
  validates :display_name, presence: true, length: { maximum: 255 }
  validates :is_collection, inclusion: { in: [true, false] }

  scope :collections, -> { where(is_collection: true) }
  scope :singles, -> { where(is_collection: false) }
end
