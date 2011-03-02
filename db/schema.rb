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

ActiveRecord::Schema.define(:version => 20110227054459) do

  create_table "ars_reviews", :force => true do |t|
    t.string   "article_title"
    t.string   "link"
    t.string   "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ars_reviews", ["link"], :name => "index_ars_reviews_on_link", :unique => true

  create_table "ars_titles", :force => true do |t|
    t.string   "title"
    t.integer  "ars_review_id"
    t.decimal  "percent_appears", :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "jobstates", :force => true do |t|
    t.string   "name"
    t.boolean  "running"
    t.date     "started"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "loves", :force => true do |t|
    t.integer  "ars_review_id"
    t.string   "gb_title"
    t.string   "title"
    t.boolean  "owned"
    t.boolean  "ignored"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shop_list_items", :force => true do |t|
    t.integer  "ars_review_id"
    t.integer  "loves_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
