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

ActiveRecord::Schema.define(:version => 20130530210548) do

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.integer  "project_id"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "comments", ["project_id"], :name => "index_comments_on_project_id"

  create_table "contacts", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "position"
    t.integer  "project_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "contacts", ["organization_id"], :name => "index_contacts_on_organization_id"
  add_index "contacts", ["project_id"], :name => "index_contacts_on_project_id"

  create_table "contents", :force => true do |t|
    t.string   "content_type"
    t.string   "name"
    t.text     "content"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

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
  add_index "countries", ["iso3"], :name => "index_countries_on_iso3"
  add_index "countries", ["name"], :name => "index_countries_on_name"

  create_table "crs_sectors", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "currencies", :force => true do |t|
    t.string   "name"
    t.string   "iso3"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "currencies", ["iso3"], :name => "index_currencies_on_iso3"
  add_index "currencies", ["name"], :name => "index_currencies_on_name"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "document_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "document_types", ["name"], :name => "index_document_types_on_name"

  create_table "exports", :force => true do |t|
    t.string   "email"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "status_percent"
    t.string   "file_path"
    t.boolean  "mailed_status"
  end

  create_table "exports_projects", :id => false, :force => true do |t|
    t.integer "export_id"
    t.integer "project_id"
  end

  add_index "exports_projects", ["export_id", "project_id"], :name => "index_exports_projects_on_export_id_and_project_id"
  add_index "exports_projects", ["project_id", "export_id"], :name => "index_exports_projects_on_project_id_and_export_id"

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

  add_index "flags", ["flag_type_id"], :name => "index_flags_on_flag_type_id"
  add_index "flags", ["flaggable_id", "flaggable_type"], :name => "index_flags_on_flaggable_id_and_flaggable_type"
  add_index "flags", ["flaggable_id"], :name => "index_flags_on_flaggable_id"
  add_index "flags", ["flaggable_type"], :name => "index_flags_on_flaggable_type"

  create_table "flow_classes", :force => true do |t|
    t.integer  "project_id"
    t.integer  "oda_like_1_id"
    t.integer  "oda_like_2_id"
    t.integer  "oda_like_master_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "flow_classes", ["oda_like_1_id"], :name => "index_flow_classes_on_oda_like_1_id"
  add_index "flow_classes", ["oda_like_2_id"], :name => "index_flow_classes_on_oda_like_2_id"
  add_index "flow_classes", ["oda_like_master_id"], :name => "index_flow_classes_on_oda_like_master_id"
  add_index "flow_classes", ["project_id"], :name => "index_flow_classes_on_project_id"

  create_table "flow_types", :force => true do |t|
    t.string   "name"
    t.integer  "iati_code"
    t.integer  "aiddata_code"
    t.integer  "oecd_code"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "flow_types", ["id"], :name => "index_flow_types_on_id"
  add_index "flow_types", ["name"], :name => "index_flow_types_on_name"

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
  add_index "geopoliticals", ["recipient_id"], :name => "index_geopoliticals_on_recipient_id"

  create_table "intents", :force => true do |t|
    t.string   "name"
    t.integer  "code"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "intents", ["name"], :name => "index_intents_on_name"

  create_table "loan_details", :force => true do |t|
    t.integer  "project_id"
    t.integer  "loan_type_id"
    t.float    "interest_rate"
    t.integer  "maturity"
    t.integer  "grace_period"
    t.float    "grant_element"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.datetime "time_calculated"
  end

  add_index "loan_details", ["loan_type_id"], :name => "index_loan_details_on_loan_type_id"
  add_index "loan_details", ["project_id"], :name => "index_loan_details_on_project_id"

  create_table "loan_types", :force => true do |t|
    t.string   "name"
    t.string   "description"
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
  add_index "oda_likes", ["name"], :name => "index_oda_likes_on_name"

  create_table "organization_types", :force => true do |t|
    t.string   "name"
    t.integer  "iati_code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "organization_types", ["name"], :name => "index_organization_types_on_name"

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "organization_type_id"
  end

  add_index "organizations", ["id"], :name => "index_organizations_on_id"
  add_index "organizations", ["name"], :name => "index_organizations_on_name"
  add_index "organizations", ["organization_type_id"], :name => "index_organizations_on_organization_type_id"

  create_table "origins", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "origins", ["name"], :name => "index_origins_on_name"

  create_table "participating_organizations", :force => true do |t|
    t.integer  "role_id"
    t.integer  "project_id"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "origin_id"
  end

  add_index "participating_organizations", ["organization_id"], :name => "index_participating_organizations_on_organization_id"
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
    t.integer  "crs_sector_id"
    t.text     "last_state"
  end

  add_index "projects", ["active"], :name => "index_projects_on_active"
  add_index "projects", ["crs_sector"], :name => "index_projects_on_crs_sector"
  add_index "projects", ["donor_id"], :name => "index_projects_on_donor_id"
  add_index "projects", ["flow_type_id"], :name => "index_projects_on_flow_type_id"
  add_index "projects", ["id"], :name => "index_projects_on_id"
  add_index "projects", ["intent_id"], :name => "index_projects_on_intent_id"
  add_index "projects", ["sector_id"], :name => "index_projects_on_sector_id"
  add_index "projects", ["status_id"], :name => "index_projects_on_status_id"
  add_index "projects", ["title"], :name => "index_projects_on_title"
  add_index "projects", ["verified_id"], :name => "index_projects_on_verified_id"
  add_index "projects", ["year"], :name => "index_projects_on_year"

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.string   "followed_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "remittances", :id => false, :force => true do |t|
    t.string  "year"
    t.string  "country"
    t.decimal "amount",  :precision => 255, :scale => 0
  end

  create_table "resources", :force => true do |t|
    t.string   "title"
    t.text     "authors"
    t.string   "publisher"
    t.date     "publish_date"
    t.string   "publisher_location"
    t.datetime "fetched_at"
    t.string   "download_url"
    t.boolean  "dont_fetch"
    t.string   "resource_type"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "source_url"
  end

  create_table "review_entries", :force => true do |t|
    t.string   "status",          :default => "OPEN"
    t.text     "serialized_item"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "ar_model"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "iati_code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "scope_channels", :force => true do |t|
    t.integer  "scope_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "scope_channels", ["scope_id"], :name => "index_scope_channels_on_scope_id"

  create_table "scope_filter_values", :force => true do |t|
    t.string   "value"
    t.integer  "scope_filter_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "scope_filter_values", ["scope_filter_id"], :name => "index_scope_filter_values_on_scope_filter_id"

  create_table "scope_filters", :force => true do |t|
    t.string   "field"
    t.integer  "scope_channel_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "scope_filters", ["scope_channel_id"], :name => "index_scope_filters_on_scope_channel_id"

  create_table "scopes", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "symbol"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "scopes", ["name"], :name => "index_scopes_on_name"
  add_index "scopes", ["symbol"], :name => "index_scopes_on_symbol"

  create_table "sectors", :force => true do |t|
    t.string   "name"
    t.integer  "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "color"
  end

  add_index "sectors", ["id"], :name => "index_sectors_on_id"
  add_index "sectors", ["name"], :name => "index_sectors_on_name"

  create_table "source_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "source_types", ["name"], :name => "index_source_types_on_name"

  create_table "sources", :force => true do |t|
    t.integer  "source_type_id"
    t.integer  "document_type_id"
    t.string   "url"
    t.date     "date"
    t.integer  "project_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "sources", ["document_type_id"], :name => "index_sources_on_document_type_id"
  add_index "sources", ["project_id"], :name => "index_sources_on_project_id"
  add_index "sources", ["source_type_id"], :name => "index_sources_on_source_type_id"

  create_table "statuses", :force => true do |t|
    t.string   "name"
    t.integer  "iati_code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "code"
  end

  add_index "statuses", ["id"], :name => "index_statuses_on_id"
  add_index "statuses", ["name"], :name => "index_statuses_on_name"

  create_table "tieds", :force => true do |t|
    t.string   "name"
    t.integer  "iati_code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "code"
  end

  add_index "tieds", ["id"], :name => "index_tieds_on_id"

  create_table "transactions", :force => true do |t|
    t.float    "value"
    t.integer  "currency_id"
    t.float    "usd_defl"
    t.integer  "project_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.float    "deflator"
    t.float    "exchange_rate"
    t.datetime "deflated_at"
    t.float    "usd_current"
  end

  add_index "transactions", ["currency_id"], :name => "index_transactions_on_currency_id"
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
    t.string   "provider"
    t.string   "uid"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
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
    t.text     "children"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
