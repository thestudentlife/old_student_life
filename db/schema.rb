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

ActiveRecord::Schema.define(:version => 20110528231825) do

  create_table "articles", :id => false, :force => true do |t|
    t.integer  "id",            :limit => 11, :null => false
    t.integer  "headline_id",   :limit => 11
    t.integer  "section_id",    :limit => 11
    t.integer  "subsection_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "issue_id",      :limit => 11
    t.text     "body"
    t.boolean  "published"
    t.datetime "published_at"
    t.string   "title"
  end

  create_table "articles_authors", :id => false, :force => true do |t|
    t.integer "article_id", :limit => 11, :null => false
    t.integer "author_id",  :limit => 11, :null => false
  end

  create_table "authors", :id => false, :force => true do |t|
    t.integer "id",      :limit => 11, :null => false
    t.integer "user_id", :limit => 11
    t.string  "name"
  end

  create_table "forms", :id => false, :force => true do |t|
    t.integer  "id",         :limit => 11, :null => false
    t.string   "name"
    t.string   "definition"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "front_page_articles", :id => false, :force => true do |t|
    t.integer  "id",         :limit => 11, :null => false
    t.integer  "article_id", :limit => 11, :null => false
    t.integer  "priority",   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :id => false, :force => true do |t|
    t.integer  "id",                 :limit => 11,                :null => false
    t.integer  "article_id",         :limit => 11,                :null => false
    t.integer  "published_online",   :limit => 1,  :default => 0
    t.integer  "published_in_print", :limit => 1,  :default => 0
    t.string   "caption"
    t.string   "credit"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size",     :limit => 11
    t.datetime "file_updated_at"
  end

  create_table "in_copy_articles", :id => false, :force => true do |t|
    t.integer  "id",               :limit => 11, :null => false
    t.integer  "article_id",       :limit => 11
    t.string   "lockfile"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "lockfile_content"
    t.text     "header"
  end

  create_table "issues", :id => false, :force => true do |t|
    t.integer  "id",         :limit => 11, :null => false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "review_slots", :id => false, :force => true do |t|
    t.integer  "id",             :limit => 11, :null => false
    t.string   "name"
    t.integer  "requires_admin", :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "revisions", :id => false, :force => true do |t|
    t.integer  "id",         :limit => 11, :null => false
    t.integer  "article_id", :limit => 11, :null => false
    t.integer  "author_id",  :limit => 11, :null => false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sections", :id => false, :force => true do |t|
    t.integer  "id",         :limit => 11, :null => false
    t.string   "name",                     :null => false
    t.integer  "priority",   :limit => 11, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
  end

  create_table "submissions", :id => false, :force => true do |t|
    t.integer  "id",         :limit => 11, :null => false
    t.integer  "form_id",    :limit => 11
    t.string   "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_sessions", :id => false, :force => true do |t|
    t.integer  "id",         :limit => 11, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :id => false, :force => true do |t|
    t.integer  "id",                 :limit => 11,                  :null => false
    t.string   "email",                                             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_admin",           :limit => 1,   :default => 0
    t.string   "encrypted_password", :limit => 128, :default => "", :null => false
  end

  create_table "viewed_articles", :id => false, :force => true do |t|
    t.integer  "id",         :limit => 11, :null => false
    t.integer  "article_id", :limit => 11, :null => false
    t.datetime "created_at"
  end

  create_table "workflow_articles", :force => true do |t|
    t.integer  "article_id"
    t.string   "status_message"
    t.string   "name"
    t.string   "proposed_titles"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "locked_by"
  end

  create_table "workflow_comments", :id => false, :force => true do |t|
    t.integer  "id",         :limit => 11, :null => false
    t.integer  "article_id", :limit => 11, :null => false
    t.integer  "author_id",  :limit => 11, :null => false
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflow_reviews", :id => false, :force => true do |t|
    t.integer  "id",             :limit => 11, :null => false
    t.integer  "review_slot_id", :limit => 11, :null => false
    t.integer  "article_id",     :limit => 11, :null => false
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "author_id",      :limit => 11
  end

  create_table "workflow_updates", :id => false, :force => true do |t|
    t.integer  "id",         :limit => 11, :null => false
    t.integer  "article_id", :limit => 11, :null => false
    t.integer  "author_id",  :limit => 11, :null => false
    t.string   "updates"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
