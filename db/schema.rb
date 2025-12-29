# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 0) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "admin_auth0_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "admin_id", null: false
    t.uuid "auth0_account_id", null: false
    t.citext "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "idx_admin_auth0_accounts_admin_uniq", unique: true
    t.index ["auth0_account_id"], name: "index_admin_auth0_accounts_on_auth0_account_id"
    t.index ["tenant_id"], name: "idx_admin_auth0_accounts_tenant"
  end

  create_table "admins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "idx_admins_tenant_id"
  end

  create_table "auth0_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "uid", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "idx_auth0_accounts_email_uniq", unique: true
    t.index ["uid"], name: "idx_auth0_accounts_uid_uniq", unique: true
  end

  create_table "content_authorization_tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "remote_id", comment: "External system ID for synchronization"
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "id"], name: "index_content_authorization_tags_on_tenant_id_and_id", unique: true
    t.index ["tenant_id", "name"], name: "index_content_authorization_tags_on_tenant_id_and_name", unique: true
    t.index ["tenant_id", "remote_id"], name: "index_content_authorization_tags_on_tenant_id_and_remote_id", unique: true, where: "(remote_id IS NOT NULL)"
  end

  create_table "content_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "content_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "content_type_id", "id"], name: "index_content_entries_on_tenant_id_and_content_type_id_and_id", unique: true
    t.index ["tenant_id", "id"], name: "index_content_entries_on_tenant_id_and_id", unique: true
  end

  create_table "content_entry_authorizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "content_entry_id", null: false
    t.integer "version", null: false
    t.uuid "content_authorization_tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_authorization_tag_id"], name: "index_content_entry_authorizations_on_tag"
    t.index ["tenant_id", "content_entry_id", "version", "content_authorization_tag_id"], name: "index_content_entry_authorizations_unique", unique: true
    t.index ["tenant_id", "id"], name: "index_content_entry_authorizations_on_tenant_id_and_id", unique: true
  end

  create_table "content_entry_field_media_assets", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.integer "media_type", null: false
    t.uuid "media_asset_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "id"], name: "index_content_entry_field_media_assets_on_tenant_id_and_id", unique: true
  end

  create_table "content_entry_field_richtexts", force: :cascade do |t|
    t.jsonb "value", null: false
  end

  create_table "content_entry_field_select_selections", force: :cascade do |t|
    t.bigint "content_entry_field_select_id", null: false
    t.bigint "option_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_entry_field_select_id", "option_id"], name: "idx_field_select_selections_unique", unique: true
  end

  create_table "content_entry_field_selects", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "id"], name: "index_content_entry_field_selects_on_tenant_id_and_id", unique: true
  end

  create_table "content_entry_field_texts", force: :cascade do |t|
    t.text "value", null: false
  end

  create_table "content_entry_fields", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "content_type_id", null: false
    t.uuid "content_entry_id", null: false
    t.integer "version", null: false
    t.integer "content_type_field_id", null: false
    t.integer "field_type", null: false
    t.integer "text_id"
    t.integer "richtext_id"
    t.integer "media_asset_id"
    t.bigint "select_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "content_entry_versions", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "content_type_id", null: false
    t.uuid "content_entry_id", null: false
    t.integer "version", default: 1, null: false
    t.integer "status", null: false
    t.boolean "is_public", default: false, null: false
    t.integer "visibility", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "published_at"
    t.datetime "unpublished_at"
    t.index ["content_entry_id", "version"], name: "index_content_entry_versions_on_entry_version", unique: true
    t.index ["tenant_id", "content_type_id", "content_entry_id", "version"], name: "index_content_entry_versions_on_tenant_type_entry_version", unique: true
    t.index ["tenant_id", "is_public"], name: "index_content_entry_versions_on_tenant_is_public"
    t.index ["tenant_id", "visibility"], name: "index_content_entry_versions_on_tenant_visibility"
  end

  create_table "content_type_field_media_assets", force: :cascade do |t|
  end

  create_table "content_type_field_richtexts", force: :cascade do |t|
  end

  create_table "content_type_field_select_options", force: :cascade do |t|
    t.bigint "field_select_id", null: false
    t.text "display_name", null: false
    t.text "identifier", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field_select_id", "identifier"], name: "idx_on_field_select_id_identifier_c909d81143", unique: true
    t.index ["field_select_id", "position"], name: "idx_on_field_select_id_position_9d0ef88527"
  end

  create_table "content_type_field_selects", force: :cascade do |t|
    t.integer "display_format", default: 0, null: false
    t.bigint "default_option_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "content_type_field_texts", force: :cascade do |t|
  end

  create_table "content_type_fields", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "content_type_id", null: false
    t.text "api_identifier", null: false
    t.text "label", null: false
    t.integer "field_type", null: false
    t.integer "text_id"
    t.integer "richtext_id"
    t.integer "media_asset_id"
    t.bigint "select_id"
    t.text "description", default: "", null: false
    t.boolean "required", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_type_id", "api_identifier"], name: "idx_on_content_type_id_api_identifier_0e95c10a8a", unique: true
    t.index ["content_type_id", "position"], name: "index_content_type_fields_on_content_type_id_and_position"
    t.index ["tenant_id", "content_type_id", "id", "field_type"], name: "idx_on_tenant_id_content_type_id_id_field_type_db01de1ec3", unique: true
    t.index ["tenant_id", "content_type_id", "id"], name: "idx_on_tenant_id_content_type_id_id_01457429a3", unique: true
  end

  create_table "content_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.boolean "is_collection", default: true, null: false
    t.text "display_name"
    t.text "unique_name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "tenant_id"], name: "index_content_types_on_id_and_tenant_id", unique: true
    t.index ["tenant_id", "id"], name: "index_content_types_on_tenant_id_and_id", unique: true
  end

  create_table "media_assets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.integer "media_type", null: false
    t.string "mime_type", null: false
    t.bigint "file_size_bytes", null: false
    t.string "s3_object_path", null: false
    t.jsonb "metadata", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "media_type"], name: "index_media_assets_on_id_and_media_type", unique: true
    t.index ["tenant_id", "id", "media_type"], name: "index_media_assets_on_tenant_id_and_id_and_media_type", unique: true
    t.index ["tenant_id", "media_type", "id"], name: "index_media_assets_on_tenant_id_and_media_type_and_id", unique: true
  end

  create_table "oauth_providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.string "kind", default: "user", null: false, comment: "user or admin"
    t.string "client_id", null: false
    t.string "client_secret"
    t.string "endpoint_base", null: false
    t.string "scopes", default: "", null: false
    t.string "keypath_uid", comment: "UIDを取得するためのkeypath (デフォルト: sub)"
    t.integer "session_expires_in", default: 7776000, null: false, comment: "セッショントークンの有効期間 (90 days)"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "kind"], name: "index_oauth_providers_on_tenant_id_and_kind", unique: true, where: "((kind)::text = 'user'::text)"
    t.index ["tenant_id"], name: "index_oauth_providers_on_tenant_id"
  end

  create_table "ruler_auth0_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "ruler_id", null: false
    t.uuid "auth0_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auth0_account_id"], name: "index_ruler_auth0_accounts_on_auth0_account_id"
    t.index ["ruler_id"], name: "idx_ruler_auth0_accounts_ruler_uniq", unique: true
  end

  create_table "rulers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "session_tokens", id: :string, force: :cascade do |t|
    t.string "tenant_id", null: false
    t.uuid "user_id", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "idx_session_tokens_expires_at"
    t.index ["tenant_id"], name: "idx_session_tokens_tenant_id"
    t.index ["updated_at"], name: "idx_session_tokens_updated_at"
    t.index ["user_id"], name: "idx_session_tokens_user_id"
    t.index ["user_id"], name: "index_session_tokens_on_user_id"
  end

  create_table "tenants", id: :string, force: :cascade do |t|
    t.string "name"
    t.string "user_page_domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "user_id", null: false
    t.uuid "content_authorization_tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_authorization_tag_id"], name: "index_user_tags_on_tag"
    t.index ["tenant_id", "id"], name: "index_user_tags_on_tenant_id_and_id", unique: true
    t.index ["tenant_id", "user_id", "content_authorization_tag_id"], name: "index_user_tags_unique", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "oauth_provider_id", null: false
    t.string "uid", null: false, comment: "IDP platform user ID"
    t.datetime "last_authenticated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["oauth_provider_id"], name: "index_users_on_oauth_provider_id"
    t.index ["tenant_id", "id"], name: "index_users_on_tenant_id_and_id", unique: true
    t.index ["tenant_id", "uid"], name: "index_users_on_tenant_id_and_uid", unique: true
  end

  add_foreign_key "admin_auth0_accounts", "admins", name: "fk_admin_auth0_accounts_admins"
  add_foreign_key "admin_auth0_accounts", "auth0_accounts", name: "fk_admin_auth0_accounts_auth0_accounts"
  add_foreign_key "admin_auth0_accounts", "tenants", name: "fk_admin_auth0_accounts_tenants"
  add_foreign_key "admins", "tenants", name: "fk_admins_tenants"
  add_foreign_key "content_authorization_tags", "tenants"
  add_foreign_key "content_entries", "content_types", column: ["tenant_id", "content_type_id"], primary_key: ["tenant_id", "id"]
  add_foreign_key "content_entry_authorizations", "content_authorization_tags"
  add_foreign_key "content_entry_authorizations", "content_entry_versions", column: ["content_entry_id", "version"], primary_key: ["content_entry_id", "version"], name: "fk_content_entry_authorizations_versions"
  add_foreign_key "content_entry_authorizations", "tenants"
  add_foreign_key "content_entry_field_media_assets", "media_assets", column: ["tenant_id", "media_type", "media_asset_id"], primary_key: ["tenant_id", "media_type", "id"], name: "fk_content_entry_field_media_assets_media_assets"
  add_foreign_key "content_entry_field_select_selections", "content_entry_field_selects"
  add_foreign_key "content_entry_field_select_selections", "content_type_field_select_options", column: "option_id"
  add_foreign_key "content_entry_field_selects", "tenants"
  add_foreign_key "content_entry_fields", "content_entry_field_media_assets", column: ["tenant_id", "media_asset_id"], primary_key: ["tenant_id", "id"], name: "fk_content_entry_fields_media_assets"
  add_foreign_key "content_entry_fields", "content_entry_field_richtexts", column: "richtext_id"
  add_foreign_key "content_entry_fields", "content_entry_field_selects", column: ["tenant_id", "select_id"], primary_key: ["tenant_id", "id"], name: "fk_content_entry_fields_selects"
  add_foreign_key "content_entry_fields", "content_entry_field_texts", column: "text_id"
  add_foreign_key "content_entry_fields", "content_entry_versions", column: ["tenant_id", "content_type_id", "content_entry_id", "version"], primary_key: ["tenant_id", "content_type_id", "content_entry_id", "version"], name: "fk_content_entry_fields_content_entry_versions"
  add_foreign_key "content_entry_fields", "content_type_fields", column: ["tenant_id", "content_type_id", "content_type_field_id", "field_type"], primary_key: ["tenant_id", "content_type_id", "id", "field_type"], name: "fk_content_entry_fields_content_type_fields"
  add_foreign_key "content_entry_versions", "content_entries", column: ["tenant_id", "content_type_id", "content_entry_id"], primary_key: ["tenant_id", "content_type_id", "id"], name: "fk_content_entry_versions_content_entries"
  add_foreign_key "content_type_field_select_options", "content_type_field_selects", column: "field_select_id"
  add_foreign_key "content_type_field_selects", "content_type_field_select_options", column: "default_option_id"
  add_foreign_key "content_type_fields", "content_type_field_media_assets", column: "media_asset_id"
  add_foreign_key "content_type_fields", "content_type_field_richtexts", column: "richtext_id"
  add_foreign_key "content_type_fields", "content_type_field_selects", column: "select_id"
  add_foreign_key "content_type_fields", "content_type_field_texts", column: "text_id"
  add_foreign_key "content_type_fields", "content_types", column: ["tenant_id", "content_type_id"], primary_key: ["tenant_id", "id"]
  add_foreign_key "content_types", "tenants"
  add_foreign_key "oauth_providers", "tenants"
  add_foreign_key "ruler_auth0_accounts", "auth0_accounts", name: "fk_ruler_auth0_accounts_auth0_accounts"
  add_foreign_key "ruler_auth0_accounts", "rulers", name: "fk_ruler_auth0_accounts_rulers"
  add_foreign_key "session_tokens", "tenants"
  add_foreign_key "session_tokens", "users"
  add_foreign_key "user_tags", "content_authorization_tags"
  add_foreign_key "user_tags", "tenants"
  add_foreign_key "user_tags", "users", column: ["tenant_id", "user_id"], primary_key: ["tenant_id", "id"], name: "fk_user_tags_users"
  add_foreign_key "users", "oauth_providers"
  add_foreign_key "users", "tenants"
end
