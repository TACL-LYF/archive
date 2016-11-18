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

ActiveRecord::Schema.define(version: 20161118004457) do

  create_table "campers", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "birthdate"
    t.integer  "gender"
    t.string   "email"
    t.text     "medical_conditions_and_medication"
    t.text     "diet_and_food_allergies"
    t.integer  "status",                            default: 0
    t.integer  "family_id"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.index ["family_id"], name: "index_campers_on_family_id"
  end

  create_table "camps", force: :cascade do |t|
    t.string   "name"
    t.integer  "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["year"], name: "index_camps_on_year", unique: true
  end

  create_table "families", force: :cascade do |t|
    t.string   "primary_parent_first_name"
    t.string   "primary_parent_last_name"
    t.string   "primary_parent_email"
    t.string   "primary_parent_phone_number"
    t.string   "secondary_parent_first_name"
    t.string   "secondary_parent_last_name"
    t.string   "secondary_parent_email"
    t.string   "secondary_parent_phone_number"
    t.string   "suite"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "referral_methods", force: :cascade do |t|
    t.string   "name"
    t.boolean  "allow_details"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "referrals", force: :cascade do |t|
    t.string   "details"
    t.integer  "family_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "referral_method_id"
    t.index ["family_id", "referral_method_id"], name: "index_referrals_on_family_id_and_referral_method_id", unique: true
    t.index ["family_id"], name: "index_referrals_on_family_id"
    t.index ["referral_method_id"], name: "index_referrals_on_referral_method_id"
  end

  create_table "registrations", force: :cascade do |t|
    t.integer  "grade"
    t.integer  "shirt_size"
    t.boolean  "bus"
    t.text     "additional_notes"
    t.string   "waiver_signature"
    t.datetime "waiver_date"
    t.integer  "group"
    t.string   "camp_family"
    t.string   "cabin"
    t.string   "city"
    t.string   "state"
    t.integer  "camp_id"
    t.integer  "camper_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.text     "additional_shirts"
    t.index ["camp_id", "camper_id"], name: "index_registrations_on_camp_id_and_camper_id", unique: true
    t.index ["camp_id"], name: "index_registrations_on_camp_id"
    t.index ["camper_id"], name: "index_registrations_on_camper_id"
  end

end
