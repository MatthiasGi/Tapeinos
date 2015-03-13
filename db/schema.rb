# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 40) do

  create_table "events", force: :cascade do |t|
    t.datetime "date",       null: false
    t.string   "title"
    t.string   "location"
    t.integer  "needed"
    t.integer  "plan_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "events", ["plan_id"], name: "index_events_on_plan_id"

  create_table "plans", force: :cascade do |t|
    t.string   "title",      null: false
    t.text     "remark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "servers", force: :cascade do |t|
    t.string   "firstname",               null: false
    t.string   "lastname",                null: false
    t.string   "email"
    t.date     "birthday"
    t.integer  "sex"
    t.integer  "size_talar"
    t.integer  "size_rochet"
    t.date     "since"
    t.integer  "rank",        default: 0, null: false
    t.datetime "last_used"
    t.string   "seed"
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "servers", ["seed"], name: "index_servers_on_seed"
  add_index "servers", ["user_id"], name: "index_servers_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                                  null: false
    t.string   "password_digest",                        null: false
    t.datetime "last_used"
    t.boolean  "admin",                  default: false, null: false
    t.string   "password_reset_token"
    t.datetime "password_reset_expire"
    t.integer  "failed_authentications", default: 0,     null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "users", ["email"], name: "index_users_on_email"

end
