# typed: false

class User < ApplicationRecord
  validates :tenant_id, presence: true
end
