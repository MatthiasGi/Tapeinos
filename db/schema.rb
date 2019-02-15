# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 100) do

  create_table "events", force: :cascade do |t|
    t.datetime "date", null: false
    t.string "title"
    t.string "location"
    t.integer "needed", default: 1, null: false
    t.integer "plan_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_id"], name: "index_events_on_plan_id"
  end

  create_table "events_servers", id: false, force: :cascade do |t|
    t.integer "event_id"
    t.integer "server_id"
    t.index ["event_id"], name: "index_events_servers_on_event_id"
    t.index ["server_id"], name: "index_events_servers_on_server_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "subject", null: false
    t.text "text", null: false
    t.datetime "date", null: false
    t.integer "state", default: 0, null: false
    t.integer "user_id", null: false
    t.integer "plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "messages_servers", id: false, force: :cascade do |t|
    t.integer "message_id"
    t.integer "server_id"
    t.index ["message_id"], name: "index_messages_servers_on_message_id"
    t.index ["server_id"], name: "index_messages_servers_on_server_id"
  end

  create_table "plans", force: :cascade do |t|
    t.string "title", null: false
    t.text "remark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plans_servers", id: false, force: :cascade do |t|
    t.integer "plan_id"
    t.integer "server_id"
    t.index ["plan_id"], name: "index_plans_servers_on_plan_id"
    t.index ["server_id"], name: "index_plans_servers_on_server_id"
  end

  create_table "servers", force: :cascade do |t|
    t.string "firstname", null: false
    t.string "lastname", null: false
    t.string "email"
    t.date "birthday"
    t.integer "sex", null: false
    t.integer "size_talar"
    t.integer "size_rochet"
    t.date "since"
    t.integer "rank", default: 0, null: false
    t.datetime "last_used"
    t.string "seed"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_key"
    t.index ["seed"], name: "index_servers_on_seed"
    t.index ["user_id"], name: "index_servers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "last_used"
    t.integer "role", default: 0, null: false
    t.string "password_reset_token"
    t.datetime "password_reset_expire"
    t.integer "failed_authentications", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
  end

end
