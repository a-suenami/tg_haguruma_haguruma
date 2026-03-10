# typed: false
# frozen_string_literal: true

# 斧琴菊テナントのフィーチャー用エントリ作成
# - ニュース 5件
# - ブログ 5件
# - チケット 3件
# - プロフィール 1件（シングルトン）

require_relative '../../tenant_domain_helper'

tenant_id = TenantDomainHelper.tenant_id_for('yokikotokiku')

# =============================================================================
# ヘルパーメソッド
# =============================================================================

def richtext_content(text)
  {
    'root' => {
      'type' => 'root',
      'version' => 1,
      'direction' => 'ltr',
      'format' => '',
      'indent' => 0,
      'children' => [
        {
          'type' => 'paragraph',
          'version' => 1,
          'direction' => 'ltr',
          'format' => '',
          'indent' => 0,
          'children' => [
            { 'type' => 'text', 'version' => 1, 'text' => text, 'format' => 0, 'mode' => 'normal', 'style' => '' },
          ],
        },
      ],
    },
  }
end

def find_entry_by_field(content_type, field_api_identifier, value)
  field_def = content_type.fields.find_by(api_identifier: field_api_identifier)
  return nil unless field_def

  content_type.content_entries.find do |entry|
    version = entry.versions.first
    next unless version

    field = version.fields.joins(:text).find_by(content_type_field: field_def)
    field&.text&.value == value
  end
end

def create_feature_entry(content_type:, fields_params:, publish: false)
  result = AdminArea::Contents::SaveEntryService.new(
    content_type: content_type,
    content_entry: nil,
    fields_params: fields_params,
  ).call

  return nil unless result.success

  if publish
    AdminArea::Contents::PublishEntryService.new(
      content_type: content_type,
      content_entry: result.content_entry,
    ).call
  end

  result.content_entry
end

def get_category_option_id(content_type, category_unique_name)
  category_field = content_type.fields.find_by(api_identifier: 'category')
  return nil unless category_field&.select

  category_field.select.options.find_by(unique_name: category_unique_name)&.id
end

# =============================================================================
# ContentType を取得
# =============================================================================

NEWS_TYPE = ContentType.find_by(tenant_id: tenant_id, unique_name: 'news')
BLOG_TYPE = ContentType.find_by(tenant_id: tenant_id, unique_name: 'blog')
TICKET_TYPE = ContentType.find_by(tenant_id: tenant_id, unique_name: 'ticket')
BIOGRAPHY_TYPE = ContentType.find_by(tenant_id: tenant_id, unique_name: 'biography')

# =============================================================================
# ニュースエントリ
# =============================================================================

if NEWS_TYPE
  NEWS_DATA = [
    { title: '年末年始の営業について', body: '年末年始は12月31日から1月3日まで休業とさせていただきます。', category: 'news', publish: true },
    { title: '新メンバー加入のお知らせ', body: '2025年1月より新メンバーが加入することになりました。詳細は後日発表いたします。', category: 'news', publish: true },
    { title: '春のライブツアー決定！', body: '2025年春、全国ツアーの開催が決定しました。チケット情報は近日公開予定です。', category: 'special', publish: true },
    { title: 'ファンクラブ限定グッズ発売', body: 'ファンクラブ会員限定の新グッズを発売開始しました。', category: 'shipping', publish: true },
    { title: '会員証発送のお知らせ', body: '2025年度の会員証を発送いたしました。届かない場合はお問い合わせください。', category: 'mail', publish: true },
  ].freeze

  NEWS_DATA.each do |data|
    if find_entry_by_field(NEWS_TYPE, 'title', data[:title])
      puts "  news: #{data[:title]} (already exists)"
      next
    end

    category_id = get_category_option_id(NEWS_TYPE, data[:category])

    entry = create_feature_entry(
      content_type: NEWS_TYPE,
      fields_params: {
        'title' => data[:title],
        'body' => richtext_content(data[:body]),
        'category' => category_id,
      },
      publish: data[:publish],
    )

    if entry
      status = data[:publish] ? '公開済み' : '下書き'
      puts "  Created news: #{data[:title]} (#{status})"
    else
      puts "  Failed to create news: #{data[:title]}"
    end
  end
else
  puts '  news ContentType not found, skipping entries'
end

# =============================================================================
# ブログエントリ
# =============================================================================

if BLOG_TYPE
  BLOG_DATA = [
    { title: '最近ハマっている音楽について', body: '最近よく聴いている音楽を紹介します。ジャズとクラシックの融合が面白いです。', category: 'personal', publish: true },
    { title: '稽古場からこんにちは', body: '本日の稽古の様子をお届けします。皆様に良い舞台をお届けできるよう精進しております。', category: 'personal', publish: true },
    { title: '舞台裏メイキング映像', body: '先日の公演の舞台裏をムービーでお届けします。', category: 'movie', publish: true },
    { title: '公演情報のお知らせ', body: '次回公演についてスタッフよりお知らせいたします。', category: 'staff', publish: true },
    { title: '楽屋からの一コマ', body: '楽屋での様子を写真でお届けします。', category: 'personal', publish: true },
  ].freeze

  BLOG_DATA.each do |data|
    if find_entry_by_field(BLOG_TYPE, 'title', data[:title])
      puts "  blog: #{data[:title]} (already exists)"
      next
    end

    category_id = get_category_option_id(BLOG_TYPE, data[:category])

    entry = create_feature_entry(
      content_type: BLOG_TYPE,
      fields_params: {
        'title' => data[:title],
        'body' => richtext_content(data[:body]),
        'category' => category_id,
      },
      publish: data[:publish],
    )

    if entry
      status = data[:publish] ? '公開済み' : '下書き'
      puts "  Created blog: #{data[:title]} (#{status})"
    else
      puts "  Failed to create blog: #{data[:title]}"
    end
  end
else
  puts '  blog ContentType not found, skipping entries'
end

# =============================================================================
# チケットエントリ
# =============================================================================

if TICKET_TYPE
  TICKET_DATA = [
    { title: '五月大歌舞伎', body: '歌舞伎座にて開催。ファンクラブ先行受付は3月15日開始。', category: 'performance', publish: true },
    { title: '襲名披露お茶会', body: '会員限定のお茶会を開催いたします。抽選で50名様をご招待。', category: 'tea_party', publish: true },
    { title: 'トークイベント2025', body: '会員限定トークイベント。詳細は後日発表いたします。', category: 'other', publish: true },
  ].freeze

  TICKET_DATA.each do |data|
    if find_entry_by_field(TICKET_TYPE, 'title', data[:title])
      puts "  ticket: #{data[:title]} (already exists)"
      next
    end

    category_id = get_category_option_id(TICKET_TYPE, data[:category])

    entry = create_feature_entry(
      content_type: TICKET_TYPE,
      fields_params: {
        'title' => data[:title],
        'body' => richtext_content(data[:body]),
        'category' => category_id,
      },
      publish: data[:publish],
    )

    if entry
      status = data[:publish] ? '公開済み' : '下書き'
      puts "  Created ticket: #{data[:title]} (#{status})"
    else
      puts "  Failed to create ticket: #{data[:title]}"
    end
  end
else
  puts '  ticket ContentType not found, skipping entries'
end

# =============================================================================
# プロフィールエントリ（シングルトン - 1件のみ）
# =============================================================================

if BIOGRAPHY_TYPE
  # シングルトンなので既存エントリがあれば作成しない
  if BIOGRAPHY_TYPE.content_entries.exists?
    puts '  biography: (already exists)'
  else
    entry = create_feature_entry(
      content_type: BIOGRAPHY_TYPE,
      fields_params: {
        'body' => richtext_content('斧琴菊のプロフィールです。ここにプロフィールの詳細が入ります。'),
      },
      publish: true,
    )

    if entry
      puts '  Created biography (公開済み)'
    else
      puts '  Failed to create biography'
    end
  end
else
  puts '  biography ContentType not found, skipping entry'
end
