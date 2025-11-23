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

ActiveRecord::Schema[8.1].define(version: 2025_11_23_152827) do
  create_table "calendar_days", force: :cascade do |t|
    t.integer "calendar_id", null: false
    t.string "content_type"
    t.datetime "created_at", null: false
    t.integer "day_number", null: false
    t.text "description"
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

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end
end
