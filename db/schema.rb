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

ActiveRecord::Schema.define(:version => 20110305012010) do

  create_table "articles", :force => true do |t|
    t.string   "working_name"
    t.string   "status_message"
    t.boolean  "open_to_author",     :default => true
    t.boolean  "publishable",        :default => false
    t.boolean  "visible",            :default => true
    t.integer  "headline_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "workflow_status_id"
    t.integer  "section_id"
  end

  create_table "articles_staff_members", :id => false, :force => true do |t|
    t.integer "article_id",      :null => false
    t.integer "staff_member_id", :null => false
  end

  create_table "headlines", :force => true do |t|
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.integer  "article_id",                            :null => false
    t.boolean  "published_online",   :default => false
    t.boolean  "published_in_print", :default => false
    t.string   "caption"
    t.string   "credit"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  create_table "revisions", :force => true do |t|
    t.integer  "article_id",                                   :null => false
    t.integer  "author_id",                                    :null => false
    t.boolean  "visible_to_article_author", :default => true
    t.string   "title"
    t.text     "body"
    t.boolean  "published_online",          :default => false
    t.datetime "published_online_at"
    t.boolean  "published_in_print",        :default => false
    t.datetime "published_in_print_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sections", :force => true do |t|
    t.string   "name",       :null => false
    t.integer  "priority",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sections_staff_members", :id => false, :force => true do |t|
    t.integer "section_id",      :null => false
    t.integer "staff_member_id", :null => false
  end

  create_table "staff_members", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "is_admin",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_sessions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",             :null => false
    t.string   "crypted_password",  :null => false
    t.string   "password_salt",     :null => false
    t.string   "persistence_token", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "viewed_articles", :force => true do |t|
    t.integer  "article_id", :null => false
    t.datetime "created_at"
  end

  create_table "workflow_comments", :force => true do |t|
    t.integer  "article_id",                                  :null => false
    t.integer  "author_id",                                   :null => false
    t.boolean  "visible_to_article_author", :default => true
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflow_statuses", :force => true do |t|
    t.string   "name"
    t.integer  "priority",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
