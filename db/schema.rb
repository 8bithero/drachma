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

ActiveRecord::Schema[8.0].define(version: 2025_07_21_085044) do
  create_table "line_items", force: :cascade do |t|
    t.integer "statement_id", null: false
    t.string "item_type", null: false
    t.string "category"
    t.string "description"
    t.integer "amount_cents", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_line_items_on_category"
    t.index ["item_type"], name: "index_line_items_on_item_type"
    t.index ["statement_id", "item_type"], name: "index_line_items_on_statement_id_and_item_type"
    t.index ["statement_id"], name: "index_line_items_on_statement_id"
  end

  create_table "statements", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "slug", null: false
    t.string "name", null: false
    t.integer "line_items_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_income_cents", default: 0
    t.integer "total_expenditure_cents", default: 0
    t.string "ie_rating"
    t.index ["ie_rating"], name: "index_statements_on_ie_rating"
    t.index ["user_id", "slug"], name: "index_statements_on_user_id_and_slug", unique: true
    t.index ["user_id"], name: "index_statements_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "refresh_token"
    t.datetime "refresh_token_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["refresh_token"], name: "index_users_on_refresh_token", unique: true
  end

  add_foreign_key "line_items", "statements"
  add_foreign_key "statements", "users"
end
