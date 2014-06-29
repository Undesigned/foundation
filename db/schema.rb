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

ActiveRecord::Schema.define(version: 20140629040741) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: true do |t|
    t.string   "street"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.integer  "addressable_id"
    t.integer  "addressable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "links", force: true do |t|
    t.string   "href"
    t.string   "title"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "markets", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "markets", ["name"], name: "index_markets_on_name", using: :btree

  create_table "markets_users", id: false, force: true do |t|
    t.integer "market_id"
    t.integer "user_id"
  end

  add_index "markets_users", ["market_id", "user_id"], name: "index_markets_users_on_market_id_and_user_id", using: :btree
  add_index "markets_users", ["user_id"], name: "index_markets_users_on_user_id", using: :btree

  create_table "message_threads", force: true do |t|
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_threads_users", id: false, force: true do |t|
    t.integer "message_thread_id"
    t.integer "user_id"
  end

  add_index "message_threads_users", ["message_thread_id", "user_id"], name: "index_message_threads_users_on_message_thread_id_and_user_id", using: :btree
  add_index "message_threads_users", ["user_id"], name: "index_message_threads_users_on_user_id", using: :btree

  create_table "messages", force: true do |t|
    t.text     "content"
    t.string   "subject"
    t.integer  "message_thread_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "title"
    t.date     "started"
    t.date     "ended"
    t.integer  "user_id"
    t.integer  "startup_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "searches", force: true do |t|
    t.string   "content"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skills", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "skills", ["name"], name: "index_skills_on_name", using: :btree

  create_table "skills_users", id: false, force: true do |t|
    t.integer "skill_id"
    t.integer "user_id"
  end

  add_index "skills_users", ["skill_id", "user_id"], name: "index_skills_users_on_skill_id_and_user_id", using: :btree
  add_index "skills_users", ["user_id"], name: "index_skills_users_on_user_id", using: :btree

  create_table "startups", force: true do |t|
    t.string   "name"
    t.string   "company_size"
    t.string   "image"
    t.integer  "angellist_quality"
    t.text     "description"
    t.text     "byline"
    t.integer  "follower_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "startups", ["name"], name: "index_startups_on_name", using: :btree

  create_table "tokens", force: true do |t|
    t.string   "content"
    t.string   "provider"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "bio"
    t.string   "image"
    t.string   "location"
    t.text     "what_ive_built"
    t.text     "what_i_do"
    t.text     "criteria"
    t.string   "provider"
    t.string   "uid"
    t.integer  "follower_count"
    t.boolean  "investor"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["provider", "uid"], name: "index_users_on_provider_and_uid", using: :btree

end
