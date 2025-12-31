# typed: false
# frozen_string_literal: true

Dir.glob(Rails.root.join('db/fixtures/_shared/by_tenant/sample/*.rb')).sort.each do |file|
  require file
end
