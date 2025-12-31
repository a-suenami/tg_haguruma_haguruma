# typed: false
# frozen_string_literal: true

Dir.glob(Rails.root.join('db/fixtures/_shared/by_tenant/yokikotokiku/*.rb')).sort.each do |file|
  require file
end
