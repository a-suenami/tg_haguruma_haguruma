# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: tenants
#
#  id               :string           not null, primary key
#  name             :string
#  user_page_domain :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
FactoryBot.define do
  factory :tenant do
    id { 'sample' }
    name { 'Sample Tenant' }
  end
end
