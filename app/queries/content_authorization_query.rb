# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - queries - content authorization query
# ==============================================================================
#
# ユーザーがコンテンツバージョンにアクセス可能かを判定するクエリクラス
#
# 認可ルール:
# - コンテンツに認可タグが設定されていない場合 → 全員アクセス可能
# - コンテンツに認可タグが設定されている場合:
#   - ユーザーのタグ ∩ コンテンツのタグ ≠ ∅ → アクセス許可
#   - 上記以外 → アクセス拒否
#
class ContentAuthorizationQuery
  extend T::Sig

  sig { params(user: T.nilable(User), content_entry_version: ContentEntry::Version).void }
  def initialize(user:, content_entry_version:)
    @user = user
    @content_entry_version = content_entry_version
  end

  sig { returns(T::Boolean) }
  def authorized?
    content_tags = @content_entry_version.content_authorization_tags

    # コンテンツに認可タグが設定されていない場合は全員アクセス可能
    return true if content_tags.empty?

    # ユーザーが未認証の場合はアクセス拒否
    return false if @user.nil?

    user_tags = @user.content_authorization_tags

    # ユーザーのタグとコンテンツのタグに共通するものがあればアクセス許可
    (user_tags.pluck(:id) & content_tags.pluck(:id)).any?
  end

  class ContentAuthorizationError < StandardError; end
end
