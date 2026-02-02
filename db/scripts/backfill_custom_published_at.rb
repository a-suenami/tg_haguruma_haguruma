# backfill custom_published_at for content_entry_versions
#
# エントリの v1 の published_at を基準に、過去に公開されたことがある全バージョンに
# custom_published_at を設定する。
# 対象外: v1 が一度も公開されていないエントリ（v1.published_at が nil）
# 結果: status=draft かつ version=1 のもの以外すべてに非NULLの値が設定される
#
# Usage: rails runner db/scripts/backfill_custom_published_at.rb

ContentEntry.find_each do |entry|
  v1 = entry.versions.find_by(version: 1)
  next unless v1&.published_at

  entry.versions.find_each do |version|
    version.update_column(:custom_published_at, v1.published_at)
  end
end
