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

ActiveRecord::Schema[8.1].define(version: 2025_12_05_014123) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "calendar_days", force: :cascade do |t|
    t.integer "calendar_id", null: false
    t.string "content_type"
    t.datetime "created_at", null: false
    t.integer "day_number", null: false
    t.text "description"
    t.integer "display_position"
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["calendar_id", "day_number"], name: "index_calendar_days_on_calendar_id_and_day_number", unique: true
    t.index ["calendar_id"], name: "index_calendar_days_on_calendar_id"
  end

  create_table "calendar_views", force: :cascade do |t|
    t.integer "calendar_id", null: false
    t.datetime "created_at", null: false
    t.integer "day_number", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.datetime "viewed_at", null: false
    t.index ["calendar_id", "user_id", "day_number"], name: "index_calendar_views_on_calendar_user_day", unique: true
  end

  create_table "calendars", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "creator_id", null: false
    t.text "description"
    t.integer "recipient_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.index ["creator_id", "recipient_id", "year"], name: "index_calendars_on_creator_recipient_year", unique: true
    t.index ["creator_id"], name: "index_calendars_on_creator_id"
    t.index ["recipient_id"], name: "index_calendars_on_recipient_id"
  end

  create_table "request_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address", null: false
    t.string "path", null: false
    t.string "request_method"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id"
    t.index ["created_at"], name: "index_request_logs_on_created_at"
    t.index ["ip_address"], name: "index_request_logs_on_ip_address"
    t.index ["user_id"], name: "index_request_logs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "ntfy_topic"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "request_logs", "users"
end
