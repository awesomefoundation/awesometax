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

ActiveRecord::Schema.define(:version => 20131021193336) do

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "tax_id"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "messages", :force => true do |t|
    t.integer  "tax_id",                                                  :null => false
    t.integer  "user_id",                                                 :null => false
    t.integer  "status",     :default => 0,                               :null => false
    t.string   "title"
    t.text     "body",                                                    :null => false
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.string   "from",       :default => "contact@awesomefoundation.org"
  end

  create_table "pledges", :force => true do |t|
    t.integer  "user_id",                                                     :null => false
    t.integer  "tax_id"
    t.datetime "starts",                                                      :null => false
    t.datetime "ends"
    t.integer  "status",                                                      :null => false
    t.decimal  "amount",       :precision => 8, :scale => 2,                  :null => false
    t.decimal  "cumulative",   :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
    t.string   "stripe_token"
  end

  create_table "roles", :force => true do |t|
    t.integer  "kind",       :null => false
    t.integer  "user_id",    :null => false
    t.integer  "tax_id",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.string   "var",                       :null => false
    t.text     "value"
    t.integer  "target_id"
    t.string   "target_type", :limit => 30
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "settings", ["target_type", "target_id", "var"], :name => "index_settings_on_target_type_and_target_id_and_var", :unique => true

  create_table "taxes", :force => true do |t|
    t.string   "name",                        :null => false
    t.text     "description",                 :null => false
    t.integer  "owner_id",                    :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "status",       :default => 1, :null => false
    t.integer  "goal"
    t.string   "slug"
    t.string   "bank_token"
    t.string   "recipient_id"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "user_id",                                                         :null => false
    t.integer  "parent_id",                                                       :null => false
    t.decimal  "amount",      :precision => 8, :scale => 2,                       :null => false
    t.integer  "kind",                                                            :null => false
    t.integer  "method"
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.string   "parent_type",                               :default => "pledge"
  end

  create_table "users", :force => true do |t|
    t.string   "name",                                  :null => false
    t.integer  "status"
    t.string   "email",                                 :null => false
    t.string   "encrypted_password"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "authentication_token"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "url"
    t.string   "bio"
    t.string   "twitter"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
