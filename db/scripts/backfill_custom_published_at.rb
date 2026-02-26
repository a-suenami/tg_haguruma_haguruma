# backfill custom_published_at for content_entry_versions
#
# エントリの v1 の published_at を基準に、過去に公開されたことがある全バージョンに
# custom_published_at を設定する。
#
# 対象外: v1 が一度も公開されていないエントリ（v1.published_at が nil）
#
# DB check constraints に準拠するため、status によって処理を分ける:
# - draft: published_at, custom_published_at, unpublished_at を NULL にする
# - published: custom_published_at を設定（published_at は既存）
# - unpublished: custom_published_at を設定（published_at, unpublished_at は既存）
#
# Usage: rails runner db/scripts/backfill_custom_published_at.rb

Rails.logger.info 'Backfilling custom_published_at for content_entry_versions...'

# Count violations before
draft_violations = ContentEntry::Version.where(status: 1)
  .where('published_at IS NOT NULL OR unpublished_at IS NOT NULL').count
published_violations = ContentEntry::Version.where(status: 3)
  .where('published_at IS NULL OR custom_published_at IS NULL').count
unpublished_violations = ContentEntry::Version.where(status: 4)
  .where('published_at IS NULL OR custom_published_at IS NULL OR unpublished_at IS NULL').count

Rails.logger.info 'Before:'
Rails.logger.info "  Draft violations: #{draft_violations}"
Rails.logger.info "  Published violations: #{published_violations}"
Rails.logger.info "  Unpublished violations: #{unpublished_violations}"

# Fix drafts - clear published_at and unpublished_at only
# Keep custom_published_at (admin may have set display date)
ContentEntry::Version.where(status: 1)
  .where('published_at IS NOT NULL OR unpublished_at IS NOT NULL')
  .update_all(published_at: nil, unpublished_at: nil)

# Fix published - set custom_published_at from v1 or published_at
ContentEntry.find_each do |entry|
  v1 = entry.versions.find_by(version: 1)
  base_date = v1&.published_at

  entry.versions.where(status: 3).where(custom_published_at: nil).find_each do |version|
    date = base_date || version.published_at
    version.update_column(:custom_published_at, date) if date
  end

  entry.versions.where(status: 4).where(custom_published_at: nil).find_each do |version|
    date = base_date || version.published_at
    version.update_column(:custom_published_at, date) if date
  end
end

# Count violations after
draft_violations = ContentEntry::Version.where(status: 1)
  .where('published_at IS NOT NULL OR unpublished_at IS NOT NULL').count
published_violations = ContentEntry::Version.where(status: 3)
  .where('published_at IS NULL OR custom_published_at IS NULL').count
unpublished_violations = ContentEntry::Version.where(status: 4)
  .where('published_at IS NULL OR custom_published_at IS NULL OR unpublished_at IS NULL').count

Rails.logger.info 'After:'
Rails.logger.info "  Draft violations: #{draft_violations}"
Rails.logger.info "  Published violations: #{published_violations}"
Rails.logger.info "  Unpublished violations: #{unpublished_violations}"
Rails.logger.info 'Done!'
