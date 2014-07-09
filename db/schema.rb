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

ActiveRecord::Schema.define(version: 20140709175833) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: true do |t|
    t.string   "street"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.integer  "addressable_id"
    t.integer  "addressable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["addressable_id", "addressable_type"], name: "index_addresses_on_addressable_id_and_addressable_type", using: :btree

  create_table "links", force: true do |t|
    t.string   "title"
    t.string   "href"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "links", ["owner_id", "owner_type", "title"], name: "index_links_on_owner_id_and_owner_type_and_title", unique: true, using: :btree

  create_table "markets", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "markets", ["name"], name: "index_markets_on_name", unique: true, using: :btree

  create_table "markets_startups", id: false, force: true do |t|
    t.integer "market_id"
    t.integer "startup_id"
  end

  add_index "markets_startups", ["market_id", "startup_id"], name: "index_markets_startups_on_market_id_and_startup_id", unique: true, using: :btree
  add_index "markets_startups", ["startup_id"], name: "index_markets_startups_on_startup_id", using: :btree

  create_table "message_threads", force: true do |t|
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "message_threads", ["uid"], name: "index_message_threads_on_uid", unique: true, using: :btree

  create_table "message_threads_users", id: false, force: true do |t|
    t.integer "message_thread_id"
    t.integer "user_id"
  end

  add_index "message_threads_users", ["message_thread_id", "user_id"], name: "index_message_threads_users_on_message_thread_id_and_user_id", unique: true, using: :btree
  add_index "message_threads_users", ["user_id"], name: "index_message_threads_users_on_user_id", using: :btree

  create_table "messages", force: true do |t|
    t.text     "content"
    t.string   "subject"
    t.integer  "message_thread_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["message_thread_id"], name: "index_messages_on_message_thread_id", using: :btree

  create_table "meta_data", force: true do |t|
    t.string   "name"
    t.string   "value"
    t.string   "source"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "meta_data", ["owner_id", "owner_type", "name", "source"], name: "index_meta_data_on_owner_id_and_owner_type_and_name_and_source", unique: true, using: :btree

  create_table "roles", force: true do |t|
    t.string   "title"
    t.date     "started"
    t.date     "ended"
    t.boolean  "confirmed"
    t.integer  "user_id"
    t.integer  "startup_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["startup_id"], name: "index_roles_on_startup_id", using: :btree
  add_index "roles", ["user_id"], name: "index_roles_on_user_id", using: :btree

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

  add_index "skills", ["name"], name: "index_skills_on_name", unique: true, using: :btree

  create_table "skills_users", id: false, force: true do |t|
    t.integer "skill_id"
    t.integer "user_id"
  end

  add_index "skills_users", ["skill_id", "user_id"], name: "index_skills_users_on_skill_id_and_user_id", unique: true, using: :btree
  add_index "skills_users", ["user_id"], name: "index_skills_users_on_user_id", using: :btree

  create_table "startups", force: true do |t|
    t.string   "name"
    t.string   "company_size"
    t.string   "image"
    t.text     "description"
    t.text     "byline"
    t.string   "phone_number"
    t.boolean  "confirmed"
    t.integer  "total_funding"
    t.integer  "number_of_investments"
    t.string   "funding_stage"
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

  add_index "tokens", ["user_id", "provider"], name: "index_tokens_on_user_id_and_provider", unique: true, using: :btree

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
    t.boolean  "investor"
    t.integer  "birthyear"
    t.integer  "technical_points"
    t.integer  "design_points"
    t.integer  "business_points"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true, using: :btree

end
