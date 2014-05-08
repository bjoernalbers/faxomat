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

ActiveRecord::Schema.define(version: 20140508125939) do

  create_table "deliveries", force: true do |t|
    t.integer  "print_job_id",    null: false
    t.string   "print_job_state"
    t.integer  "fax_id",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deliveries", ["fax_id"], name: "index_deliveries_on_fax_id"
  add_index "deliveries", ["print_job_id"], name: "index_deliveries_on_print_job_id", unique: true

  create_table "faxes", force: true do |t|
    t.integer  "recipient_id", null: false
    t.string   "path",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "delivered_at"
    t.integer  "patient_id",   null: false
    t.integer  "print_job_id"
  end

  create_table "patients", force: true do |t|
    t.string   "first_name",    null: false
    t.string   "last_name",     null: false
    t.date     "date_of_birth", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipients", force: true do |t|
    t.string   "phone",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recipients", ["phone"], name: "index_recipients_on_phone", unique: true

end
