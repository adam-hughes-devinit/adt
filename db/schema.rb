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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130114180040) do

  create_table "caches", :force => true do |t|
    t.text     "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.integer  "project_id"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "contacts", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "position"
    t.integer  "project_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "contacts", ["project_id"], :name => "index_contacts_on_project_id"

  create_table "countries", :force => true do |t|
    t.string   "name"
    t.string   "iso3"
    t.string   "iso2"
    t.string   "oecd_name"
    t.integer  "oecd_code"
    t.integer  "cow_code"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "un_code"
    t.integer  "imf_code"
    t.integer  "aiddata_code"
  end

  add_index "countries", ["id"], :name => "index_countries_on_id"

  create_table "currencies", :force => true do |t|
    t.string   "name"
    t.string   "iso3"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "document_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "flag_types", :force => true do |t|
    t.string   "name"
    t.string   "color"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "flags", :force => true do |t|
    t.integer  "flaggable_id"
    t.string   "flaggable_type"
    t.integer  "flag_type_id"
    t.string   "source"
    t.text     "comment"
    t.integer  "owner_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "flow_classes", :force => true do |t|
    t.integer  "project_id"
    t.integer  "oda_like_1_id"
    t.integer  "oda_like_2_id"
    t.integer  "oda_like_master_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "flow_types", :force => true do |t|
    t.string   "name"
    t.integer  "iati_code"
    t.integer  "aiddata_code"
    t.integer  "oecd_code"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "flow_types", ["id"], :name => "index_flow_types_on_id"

  create_table "geopoliticals", :force => true do |t|
    t.integer  "recipient_id"
    t.integer  "region_id"
    t.integer  "project_id"
    t.string   "subnational"
    t.integer  "percent"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "geopoliticals", ["project_id"], :name => "index_geopoliticals_on_project_id"

  create_table "intents", :force => true do |t|
    t.string   "name"
    t.integer  "code"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "oda_likes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "code"
  end

  add_index "oda_likes", ["id"], :name => "index_oda_likes_on_id"

  create_table "organization_types", :force => true do |t|
    t.string   "name"
    t.integer  "iati_code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "organization_type_id"
  end

  add_index "organizations", ["id"], :name => "index_organizations_on_id"

  create_table "origins", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "participating_organizations", :force => true do |t|
    t.integer  "role_id"
    t.integer  "project_id"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "origin_id"
  end

  add_index "participating_organizations", ["project_id"], :name => "index_participating_organizations_on_project_id"

  create_table "projects", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.date     "start_planned"
    t.date     "start_actual"
    t.date     "end_planned"
    t.date     "end_actual"
    t.integer  "year"
    t.string   "capacity"
    t.integer  "flow_type_id"
    t.integer  "sector_id"
    t.string   "sector_comment"
    t.integer  "tied_id"
    t.integer  "oda_like_id"
    t.integer  "status_id"
    t.integer  "verified_id"
    t.integer  "donor_id"
    t.boolean  "is_commercial",  :default => false
    t.boolean  "active",         :default => true
    t.integer  "owner_id"
    t.integer  "media_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "crs_sector"
    t.boolean  "debt_uncertain", :default => false
    t.boolean  "year_uncertain", :default => false
    t.boolean  "line_of_credit", :default => false
    t.boolean  "is_cofinanced",  :default => false
    t.integer  "iteration",      :default => 0
    t.integer  "intent_id"
  end

  add_index "projects", ["id"], :name => "index_projects_on_id"

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.string   "followed_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "iati_code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sectors", :force => true do |t|
    t.string   "name"
    t.integer  "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "color"
  end

  add_index "sectors", ["id"], :name => "index_sectors_on_id"

  create_table "source_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sources", :force => true do |t|
    t.integer  "source_type_id"
    t.integer  "document_type_id"
    t.string   "url"
    t.date     "date"
    t.integer  "project_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "sources", ["project_id"], :name => "index_sources_on_project_id"

  create_table "statuses", :force => true do |t|
    t.string   "name"
    t.integer  "iati_code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "code"
  end

  add_index "statuses", ["id"], :name => "index_statuses_on_id"

  create_table "tieds", :force => true do |t|
    t.string   "name"
    t.integer  "iati_code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "code"
  end

  add_index "tieds", ["id"], :name => "index_tieds_on_id"

  create_table "transactions", :force => true do |t|
    t.decimal  "value"
    t.integer  "currency_id"
    t.decimal  "usd_defl"
    t.integer  "project_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.float    "deflator"
    t.float    "exchange_rate"
    t.datetime "deflated_at"
    t.float    "usd_current"
  end

  add_index "transactions", ["project_id"], :name => "index_transactions_on_project_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "remember_token"
    t.integer  "owner_id"
    t.boolean  "admin",           :default => false
  end

  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "verifieds", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "code"
  end

  add_index "verifieds", ["id"], :name => "index_verifieds_on_id"

  create_table "versions", :force => true do |t|
    t.string   "item_type",   :null => false
    t.integer  "item_id",     :null => false
    t.string   "event",       :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "accessories"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
