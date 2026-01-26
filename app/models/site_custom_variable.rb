# typed: strict
# frozen_string_literal: true

# == Schema Information
#
# Table name: site_custom_variables
#
#  id                                              :uuid             not null, primary key
#  archived_at                                     :datetime
#  boolean_value                                   :boolean
#  datetime_value                                  :datetime
#  description                                     :text             default(""), not null
#  text_value                                      :text
#  unique_name                                     :string           not null
#  variable_type(1: boolean, 2: datetime, 3: text) :integer          not null
#  created_at                                      :datetime         not null
#  updated_at                                      :datetime         not null
#  tenant_id                                       :string           not null
#
# Indexes
#
#  idx_site_custom_variables_tenant_archived  (tenant_id,archived_at)
#  idx_site_custom_variables_unique_name      (tenant_id,unique_name) UNIQUE WHERE (archived_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (tenant_id => tenants.id)
#
class SiteCustomVariable < ApplicationRecord
  extend T::Sig

  belongs_to :tenant, primary_key: :id

  enum :variable_type, { boolean: 1, datetime: 2, text: 3 }, prefix: true

  default_scope { where(tenant_id: Tenant.current_id) }

  validates :unique_name, presence: true,
                          format: { with: /\A[a-z_][a-z0-9_]*\z/ }
  validates :unique_name, uniqueness: { scope: :tenant_id, conditions: -> { where(archived_at: nil) } }
  validates :variable_type, presence: true

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }

  before_validation :clear_irrelevant_values

  sig { returns(T::Boolean) }
  def archived?
    archived_at.present?
  end

  sig { void }
  def archive!
    update!(archived_at: Time.current)
  end

  # 値を取得（型に応じた値を返す）
  sig { returns(T.nilable(T.any(T::Boolean, ActiveSupport::TimeWithZone, String))) }
  def value
    case variable_type
    when 'boolean'
      boolean_value
    when 'datetime'
      datetime_value
    when 'text'
      text_value
    end
  end

  # 値を設定（型に応じたカラムに保存）
  sig { params(val: T.nilable(T.any(T::Boolean, ActiveSupport::TimeWithZone, Time, String))).void }
  def value=(val)
    # 他の型のカラムをクリア
    self.boolean_value = nil
    self.datetime_value = nil
    self.text_value = nil

    case variable_type
    when 'boolean'
      self.boolean_value = ActiveModel::Type::Boolean.new.cast(val)
    when 'datetime'
      self.datetime_value = val.is_a?(String) ? Time.zone.parse(val) : val
    when 'text'
      self.text_value = val.to_s
    end
  end

  # 型のラベルを取得
  sig { returns(String) }
  def variable_type_label
    case variable_type
    when 'boolean'
      'フラグ'
    when 'datetime'
      '日時'
    when 'text'
      'テキスト'
    else
      variable_type.to_s
    end
  end

  private

  sig { void }
  def clear_irrelevant_values
    case variable_type
    when 'boolean'
      self.datetime_value = nil
      self.text_value = nil
    when 'datetime'
      self.boolean_value = nil
      self.text_value = nil
    when 'text'
      self.boolean_value = nil
      self.datetime_value = nil
    end
  end
end
