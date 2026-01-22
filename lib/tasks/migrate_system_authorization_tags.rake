# typed: false
# frozen_string_literal: true

namespace :authorization do
  desc 'Migrate existing data to use system authorization tags (public/member)'
  task migrate_system_tags: :environment do
    puts 'Starting system authorization tags migration...'

    Tenant.find_each do |tenant|
      Tenant.current_id = tenant.id
      puts "\nProcessing tenant: #{tenant.id}"

      migrate_existing_tags_for_tenant
      migrate_users_for_tenant
      migrate_content_entries_for_tenant
    end

    puts "\nMigration complete!"
  end

  def migrate_existing_tags_for_tenant
    puts '  Migrating existing tags...'

    updated_count = 0

    ContentAuthorizationTag.where(provider: nil).find_each do |tag|
      if tag.remote_id.present?
        tag.update!(provider: 'idp', unique_id: tag.remote_id)
      else
        tag.update!(provider: 'ruler', unique_id: SecureRandom.uuid)
      end
      updated_count += 1
    end

    puts "    Updated #{updated_count} existing tags"
  end

  def migrate_users_for_tenant
    puts '  Migrating users...'

    public_tag = ContentAuthorizationTag.public_tag
    member_tag = ContentAuthorizationTag.member_tag

    added_count = 0

    User.find_each do |user|
      [public_tag, member_tag].each do |tag|
        next if UserTag.exists?(user_id: user.id, content_authorization_tag_id: tag.id)

        UserTag.create!(user:, content_authorization_tag: tag)
        added_count += 1
      end
    end

    puts "    Added #{added_count} user tags"
  end

  def migrate_content_entries_for_tenant
    puts '  Migrating content entries...'

    public_tag = ContentAuthorizationTag.public_tag
    member_tag = ContentAuthorizationTag.member_tag

    added_count = 0
    skipped_count = 0

    ContentEntry::Version.published.find_each do |version|
      tag = case version.visibility
            when 'public'
              public_tag
            when 'authenticated'
              member_tag
            else
              skipped_count += 1
              next
      end

      next if ContentEntryAuthorization.exists?(
        content_entry_id: version.content_entry_id,
        version: version.version,
        content_authorization_tag_id: tag.id,
      )

      ContentEntryAuthorization.create!(
        content_entry_id: version.content_entry_id,
        version: version.version,
        content_authorization_tag: tag,
      )
      added_count += 1
    end

    puts "    Added #{added_count} content authorizations (skipped #{skipped_count} restricted)"
  end
end
