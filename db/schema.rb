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

ActiveRecord::Schema.define(version: 20150312084542) do

  create_table "faxes", force: true do |t|
    t.integer  "recipient_id",                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "delivered_at"
    t.string   "state"
    t.string   "title",                             null: false
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.integer  "delivery_attempts"
    t.integer  "status",                default: 0, null: false
  end

  create_table "print_jobs", force: true do |t|
    t.integer  "cups_job_id",                 null: false
    t.string   "cups_job_status"
    t.integer  "fax_id",                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",          default: 0, null: false
  end

  add_index "print_jobs", ["cups_job_id"], name: "index_print_jobs_on_cups_job_id", unique: true
  add_index "print_jobs", ["fax_id"], name: "index_print_jobs_on_fax_id"

  create_table "recipients", force: true do |t|
    t.string   "phone",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recipients", ["phone"], name: "index_recipients_on_phone", unique: true

end
