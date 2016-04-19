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

ActiveRecord::Schema.define(version: 20160418215418) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "documents", force: :cascade do |t|
    t.string   "title",             null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "file_fingerprint"
    t.integer  "report_id"
  end

  add_index "documents", ["report_id"], name: "index_documents_on_report_id", unique: true, using: :btree

  create_table "patients", force: :cascade do |t|
    t.string   "first_name",    null: false
    t.string   "last_name",     null: false
    t.datetime "date_of_birth", null: false
    t.string   "title"
    t.string   "suffix"
    t.integer  "sex"
    t.string   "number",        null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "print_jobs", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",      default: 0, null: false
    t.integer  "job_id",                  null: false
    t.string   "fax_number"
    t.integer  "printer_id",              null: false
    t.integer  "document_id",             null: false
  end

  add_index "print_jobs", ["document_id"], name: "index_print_jobs_on_document_id", using: :btree
  add_index "print_jobs", ["job_id"], name: "index_print_jobs_on_job_id", unique: true, using: :btree

  create_table "printers", force: :cascade do |t|
    t.string   "name"
    t.string   "label"
    t.integer  "dialout_prefix"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "type"
  end

  add_index "printers", ["name"], name: "index_printers_on_name", unique: true, using: :btree

  create_table "recipients", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name",  null: false
    t.string   "title"
    t.string   "suffix"
    t.string   "address"
    t.string   "zip"
    t.string   "city"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "salutation"
    t.string   "fax_number"
  end

  create_table "reports", force: :cascade do |t|
    t.integer  "user_id",      null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "patient_id",   null: false
    t.integer  "recipient_id", null: false
    t.string   "study",        null: false
    t.text     "anamnesis",    null: false
    t.text     "diagnosis"
    t.text     "findings"
    t.text     "evaluation",   null: false
    t.text     "procedure",    null: false
    t.text     "clinic"
    t.date     "study_date",   null: false
    t.datetime "verified_at"
    t.datetime "canceled_at"
  end

  add_index "reports", ["user_id"], name: "index_reports_on_user_id", using: :btree

  create_table "templates", force: :cascade do |t|
    t.string   "title"
    t.string   "subtitle"
    t.string   "short_title"
    t.string   "slogan"
    t.string   "address"
    t.string   "zip"
    t.string   "city"
    t.string   "phone"
    t.string   "fax"
    t.string   "email"
    t.string   "homepage"
    t.string   "owners"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",                          null: false
    t.string   "last_name",                           null: false
    t.string   "title"
    t.string   "username",               default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "signature_file_name"
    t.string   "signature_content_type"
    t.integer  "signature_file_size"
    t.datetime "signature_updated_at"
  end

  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  add_foreign_key "documents", "reports"
  add_foreign_key "print_jobs", "documents"
end
