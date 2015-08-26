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

ActiveRecord::Schema.define(version: 20150826111252) do

  create_table "faxes", force: :cascade do |t|
    t.integer  "recipient_id",                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",                 limit: 255, null: false
    t.string   "document_file_name",    limit: 255
    t.string   "document_content_type", limit: 255
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.integer  "status"
  end

  create_table "print_jobs", force: :cascade do |t|
    t.integer  "cups_job_id",                             null: false
    t.string   "cups_job_status", limit: 255
    t.integer  "fax_id",                                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",                      default: 0, null: false
  end

  add_index "print_jobs", ["cups_job_id"], name: "index_print_jobs_on_cups_job_id", unique: true
  add_index "print_jobs", ["fax_id"], name: "index_print_jobs_on_fax_id"

  create_table "recipients", force: :cascade do |t|
    t.string   "phone",      limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recipients", ["phone"], name: "index_recipients_on_phone", unique: true

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "title"
    t.string   "username",            default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "users", ["username"], name: "index_users_on_username", unique: true

end
