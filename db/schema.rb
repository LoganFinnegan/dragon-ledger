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

ActiveRecord::Schema[7.2].define(version: 2025_12_14_043544) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.string "game", default: "rs3", null: false
    t.integer "external_id", null: false
    t.text "description"
    t.string "icon_url"
    t.string "icon_large_url"
    t.string "item_type"
    t.boolean "members", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game", "external_id"], name: "index_items_on_game_and_external_id", unique: true
    t.index ["name"], name: "index_items_on_name"
  end

  create_table "price_snapshots", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.string "series", null: false
    t.datetime "sampled_at", null: false
    t.integer "price", null: false
    t.string "source", default: "rs3_official", null: false
    t.datetime "ingested_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id", "sampled_at"], name: "index_price_snapshots_on_item_id_and_sampled_at"
    t.index ["item_id", "series", "sampled_at"], name: "index_price_snapshots_on_item_id_and_series_and_sampled_at", unique: true
    t.index ["item_id"], name: "index_price_snapshots_on_item_id"
  end

  add_foreign_key "price_snapshots", "items"
end
