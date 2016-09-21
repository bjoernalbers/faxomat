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

ActiveRecord::Schema.define(version: 20160921222353) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string   "street",     null: false
    t.string   "city",       null: false
    t.string   "zip",        null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "deliveries", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",      default: 0, null: false
    t.integer  "job_number",              null: false
    t.string   "fax_number"
    t.integer  "printer_id",              null: false
    t.integer  "document_id",             null: false
    t.string   "type"
  end

  add_index "deliveries", ["document_id"], name: "index_deliveries_on_document_id", using: :btree
  add_index "deliveries", ["job_number"], name: "index_deliveries_on_job_number", unique: true, using: :btree

  create_table "directories", force: :cascade do |t|
    t.string   "description", null: false
    t.string   "path",        null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "documents", force: :cascade do |t|
    t.string   "title",             null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "file_fingerprint"
    t.integer  "recipient_id",      null: false
    t.integer  "report_id"
  end

  add_index "documents", ["recipient_id"], name: "index_documents_on_recipient_id", using: :btree
  add_index "documents", ["report_id"], name: "index_documents_on_report_id", using: :btree

  create_table "exports", force: :cascade do |t|
    t.string   "filename",     null: false
    t.integer  "document_id",  null: false
    t.integer  "directory_id", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "deleted_at"
  end

  add_index "exports", ["deleted_at"], name: "index_exports_on_deleted_at", using: :btree
  add_index "exports", ["directory_id"], name: "index_exports_on_directory_id", using: :btree
  add_index "exports", ["document_id"], name: "index_exports_on_document_id", using: :btree

  create_table "patients", force: :cascade do |t|
    t.string   "first_name",    null: false
    t.string   "last_name",     null: false
    t.string   "title"
    t.string   "suffix"
    t.integer  "sex"
    t.string   "number",        null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.date     "date_of_birth", null: false
  end

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
    t.string   "last_name"
    t.string   "title"
    t.string   "suffix"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "salutation"
    t.string   "fax_number"
    t.integer  "address_id"
  end

  add_index "recipients", ["address_id"], name: "index_recipients_on_address_id", using: :btree

  create_table "report_releases", force: :cascade do |t|
    t.integer  "report_id",   null: false
    t.integer  "user_id",     null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "canceled_at"
  end

  add_index "report_releases", ["canceled_at"], name: "index_report_releases_on_canceled_at", using: :btree
  add_index "report_releases", ["report_id"], name: "index_report_releases_on_report_id", unique: true, using: :btree
  add_index "report_releases", ["user_id"], name: "index_report_releases_on_user_id", using: :btree

  create_table "report_signatures", force: :cascade do |t|
    t.integer  "report_id",  null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "report_signatures", ["report_id", "user_id"], name: "index_report_signatures_on_report_id_and_user_id", unique: true, using: :btree

  create_table "reports", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "patient_id", null: false
    t.string   "study",      null: false
    t.text     "anamnesis",  null: false
    t.text     "diagnosis"
    t.text     "findings"
    t.text     "evaluation", null: false
    t.text     "procedure",  null: false
    t.text     "clinic"
    t.date     "study_date", null: false
  end

  add_index "reports", ["user_id"], name: "index_reports_on_user_id", using: :btree

  create_table "templates", force: :cascade do |t|
    t.string   "title"
    t.string   "subtitle"
    t.string   "short_title"
    t.string   "slogan"
    t.string   "owners"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "return_address"
    t.string   "contact_infos"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",                             null: false
    t.string   "last_name",                              null: false
    t.string   "title"
    t.string   "username",               default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.datetime "remember_created_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "signature_file_name"
    t.string   "signature_content_type"
    t.integer  "signature_file_size"
    t.datetime "signature_updated_at"
    t.string   "suffix"
    t.boolean  "can_release_reports",    default: false, null: false
  end

  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  add_foreign_key "deliveries", "documents"
  add_foreign_key "documents", "recipients"
  add_foreign_key "documents", "reports"
  add_foreign_key "exports", "directories"
  add_foreign_key "exports", "documents"
  add_foreign_key "recipients", "addresses"
  add_foreign_key "report_releases", "reports"
  add_foreign_key "report_releases", "users"
  add_foreign_key "report_signatures", "reports"
  add_foreign_key "report_signatures", "users"
end
