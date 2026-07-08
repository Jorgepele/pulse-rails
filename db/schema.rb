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

ActiveRecord::Schema[8.1].define(version: 2026_07_08_100317) do
  create_table "boards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_public", default: true, null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_boards_on_slug", unique: true
  end

  create_table "posts", force: :cascade do |t|
    t.integer "board_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.string "status", default: "open", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["board_id"], name: "index_posts_on_board_id"
  end

  create_table "votes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "post_id", null: false
    t.datetime "updated_at", null: false
    t.string "voter_token", null: false
    t.index ["post_id", "voter_token"], name: "index_votes_on_post_id_and_voter_token", unique: true
    t.index ["post_id"], name: "index_votes_on_post_id"
  end

  add_foreign_key "posts", "boards"
  add_foreign_key "votes", "posts"
end
