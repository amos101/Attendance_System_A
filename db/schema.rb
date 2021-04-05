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

ActiveRecord::Schema.define(version: 20200624121145) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "before_started_at"
    t.datetime "before_finished_at"
    t.datetime "edit_started_at"
    t.datetime "edit_finished_at"
    t.datetime "start_year"
    t.datetime "end_year"
    t.string "note"
    t.datetime "scheduled_end_time"
    t.string "business_processing_content"
    t.integer "instructor_confirmation", default: 0, null: false
    t.integer "instructor_confirmation_k", default: 0, null: false
    t.integer "instructor_confirmation_ok", default: 0, null: false
    t.boolean "tomorrow"
    t.boolean "tomorrow_k"
    t.boolean "change", default: false
    t.string "application"
    t.string "application_k"
    t.string "application_ok"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.string "base_name"
    t.string "attendance_type"
    t.integer "base_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "affiliation"
    t.string "employee_number"
    t.string "uid"
    t.time "basic_work_time"
    t.datetime "designated_work_start_time", default: "2021-04-03 00:00:00"
    t.datetime "designated_work_end_time", default: "2021-04-03 09:00:00"
    t.datetime "basic_time", default: "2021-04-02 23:00:00"
    t.boolean "superior_flag", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
