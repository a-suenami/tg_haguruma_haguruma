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

  create_table "content_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "content_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "content_type_id", "id"], name: "index_content_entries_on_tenant_id_and_content_type_id_and_id", unique: true
    t.index ["tenant_id", "id"], name: "index_content_entries_on_tenant_id_and_id", unique: true
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "content_entry_versions", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "content_type_id", null: false
    t.uuid "content_entry_id", null: false
    t.integer "version", default: 1, null: false
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "published_at"
    t.datetime "unpublished_at"
    t.index ["tenant_id", "content_type_id", "content_entry_id", "version"], name: "index_content_entry_versions_on_tenant_type_entry_version", unique: true
  end

  create_table "content_type_field_media_assets", force: :cascade do |t|
  end

  create_table "content_type_field_richtexts", force: :cascade do |t|
  end

  create_table "content_type_field_texts", force: :cascade do |t|
  end

  create_table "content_type_fields", force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.uuid "content_type_id", null: false
    t.string "api_identifier", limit: 32, null: false
    t.string "label", limit: 255, null: false
    t.integer "field_type", null: false
    t.integer "text_id"
    t.integer "richtext_id"
    t.integer "media_asset_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "content_type_id", "id", "field_type"], name: "index_content_type_fields_on_tenant_type_id_field_type", unique: true
    t.index ["tenant_id", "content_type_id", "id"], name: "idx_on_tenant_id_content_type_id_id_01457429a3", unique: true
  end

  create_table "content_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.boolean "is_collection", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "tenant_id"], name: "index_content_types_on_id_and_tenant_id", unique: true
    t.index ["tenant_id", "id"], name: "index_content_types_on_tenant_id_and_id", unique: true
  end

  create_table "media_assets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.integer "media_type", null: false
    t.string "mime_type", null: false
    t.jsonb "metadata", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "media_type"], name: "index_media_assets_on_id_and_media_type", unique: true
    t.index ["tenant_id", "id", "media_type"], name: "index_media_assets_on_tenant_id_and_id_and_media_type", unique: true
    t.index ["tenant_id", "media_type", "id"], name: "index_media_assets_on_tenant_id_and_media_type_and_id", unique: true
  end

  create_table "tenants", id: :string, force: :cascade do |t|
    t.string "name"
    t.string "user_page_domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "id"], name: "index_users_on_tenant_id_and_id", unique: true
  end

  add_foreign_key "content_entries", "content_types", column: ["tenant_id", "content_type_id"], primary_key: ["tenant_id", "id"]
  add_foreign_key "content_entry_field_media_assets", "media_assets", column: ["tenant_id", "media_type", "media_asset_id"], primary_key: ["tenant_id", "media_type", "id"], name: "fk_content_entry_field_media_assets_media_assets"
  add_foreign_key "content_entry_fields", "content_entry_field_media_assets", column: ["tenant_id", "media_asset_id"], primary_key: ["tenant_id", "id"], name: "fk_content_entry_fields_media_assets"
  add_foreign_key "content_entry_fields", "content_entry_field_richtexts", column: "richtext_id"
  add_foreign_key "content_entry_fields", "content_entry_field_texts", column: "text_id"
  add_foreign_key "content_entry_fields", "content_entry_versions", column: ["tenant_id", "content_type_id", "content_entry_id", "version"], primary_key: ["tenant_id", "content_type_id", "content_entry_id", "version"], name: "fk_content_entry_fields_content_entry_versions"
  add_foreign_key "content_entry_fields", "content_type_fields", column: ["tenant_id", "content_type_id", "content_type_field_id", "field_type"], primary_key: ["tenant_id", "content_type_id", "id", "field_type"], name: "fk_content_entry_fields_content_type_fields"
  add_foreign_key "content_entry_versions", "content_entries", column: ["tenant_id", "content_type_id", "content_entry_id"], primary_key: ["tenant_id", "content_type_id", "id"], name: "fk_content_entry_versions_content_entries"
  add_foreign_key "content_type_fields", "content_type_field_media_assets", column: "media_asset_id"
  add_foreign_key "content_type_fields", "content_type_field_richtexts", column: "richtext_id"
  add_foreign_key "content_type_fields", "content_type_field_texts", column: "text_id"
  add_foreign_key "content_type_fields", "content_types", column: ["tenant_id", "content_type_id"], primary_key: ["tenant_id", "id"]
  add_foreign_key "content_types", "tenants"
  add_foreign_key "users", "tenants"
end
