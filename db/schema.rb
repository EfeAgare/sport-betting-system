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

ActiveRecord::Schema[8.0].define(version: 2025_01_19_195833) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "game_id", null: false
    t.string "bet_type"
    t.string "pick"
    t.decimal "amount", precision: 15, scale: 2, default: "0.0"
    t.decimal "odds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "pending"
    t.index ["amount"], name: "index_bets_on_amount"
    t.index ["created_at"], name: "index_bets_on_created_at"
    t.index ["game_id"], name: "index_bets_on_game_id"
    t.index ["status"], name: "index_bets_on_status"
    t.index ["user_id"], name: "index_bets_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.string "event_type", null: false
    t.string "team", null: false
    t.string "player", null: false
    t.integer "minute", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_events_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "game_id", null: false
    t.string "home_team"
    t.string "away_team"
    t.integer "home_score", default: 0
    t.integer "away_score", default: 0
    t.integer "time_elapsed", default: 0
    t.string "status", default: "scheduled", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_games_on_created_at"
    t.index ["game_id"], name: "index_games_on_game_id", unique: true
  end

  create_table "jwt_blacklists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_blacklists_on_jti", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "username", null: false
    t.decimal "balance", precision: 15, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "bets", "games"
  add_foreign_key "bets", "users"
  add_foreign_key "events", "games"
end
