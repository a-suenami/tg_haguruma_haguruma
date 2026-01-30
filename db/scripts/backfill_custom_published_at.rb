# backfill custom_published_at for content_entry_versions
#
# v1 が公開済み（published_at あり）の場合のみ、その published_at を custom_published_at にコピーする。
# v1 が未公開の場合は一度も世に出ていないため、custom_published_at は null のまま。
#
# Usage: rails runner db/scripts/backfill_custom_published_at.rb

ContentEntry::Version.where(version: 1).where.not(published_at: nil).find_each do |v1|
  v1.update_column(:custom_published_at, v1.published_at)
end
