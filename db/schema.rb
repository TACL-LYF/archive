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

ActiveRecord::Schema.define(version: 20170627043900) do

  create_table "campers", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.date     "birthdate"
    t.integer  "gender"
    t.string   "email"
    t.text     "medical_conditions_and_medication"
    t.text     "diet_and_food_allergies"
    t.integer  "status",                            default: 0
    t.integer  "family_id"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.boolean  "returning"
    t.index ["family_id"], name: "index_campers_on_family_id"
  end

  create_table "camps", force: :cascade do |t|
    t.string   "name"
    t.integer  "year"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.decimal  "registration_fee",        precision: 10, scale: 2
    t.decimal  "shirt_price",             precision: 6,  scale: 2
    t.decimal  "sibling_discount",        precision: 6,  scale: 2
    t.decimal  "registration_late_fee",   precision: 6,  scale: 2
    t.date     "registration_open_date"
    t.date     "registration_late_date"
    t.date     "registration_close_date"
    t.index ["year"], name: "index_camps_on_year", unique: true
  end

  create_table "donations", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.decimal  "amount",           precision: 10, scale: 2
    t.boolean  "company_match"
    t.string   "company"
    t.string   "stripe_charge_id"
    t.string   "stripe_brand"
    t.integer  "stripe_last_four"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
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

  create_table "last_day_purchases", force: :cascade do |t|
    t.string  "first_name"
    t.string  "last_name"
    t.string  "email"
    t.string  "phone"
    t.string  "address"
    t.string  "city"
    t.string  "state"
    t.string  "zip"
    t.decimal "amount",            precision: 10, scale: 2
    t.boolean "dollar_for_dollar"
    t.string  "company"
    t.string  "stripe_charge_id"
    t.string  "stripe_brand"
    t.string  "stripe_last_four"
  end

  create_table "referral_methods", force: :cascade do |t|
    t.string   "name"
    t.boolean  "allow_details"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "details_field_label", default: "Please specify:"
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

  create_table "reg_sessions", force: :cascade do |t|
    t.text     "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "registration_discounts", force: :cascade do |t|
    t.string   "code"
    t.integer  "discount_percent"
    t.boolean  "redeemed",                default: false, null: false
    t.integer  "camp_id"
    t.integer  "registration_payment_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.index ["camp_id"], name: "index_registration_discounts_on_camp_id"
    t.index ["registration_payment_id"], name: "index_registration_discounts_on_registration_payment_id"
  end

  create_table "registration_payments", force: :cascade do |t|
    t.decimal  "total",               precision: 10, scale: 2
    t.decimal  "additional_donation", precision: 10, scale: 2
    t.string   "discount_code"
    t.string   "stripe_charge_id"
    t.text     "breakdown"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "stripe_brand"
    t.integer  "stripe_last_four"
  end

  create_table "registrations", force: :cascade do |t|
    t.integer  "grade"
    t.integer  "shirt_size"
    t.boolean  "bus"
    t.text     "additional_notes"
    t.string   "waiver_signature"
    t.date     "waiver_date"
    t.integer  "group"
    t.string   "camp_family"
    t.string   "cabin"
    t.string   "city"
    t.string   "state"
    t.integer  "camp_id"
    t.integer  "camper_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.text     "additional_shirts"
    t.integer  "registration_payment_id"
    t.text     "camper_involvement"
    t.string   "jtasa_chapter"
    t.boolean  "preregistration",         default: false
    t.integer  "status",                  default: 0,     null: false
    t.index ["camp_id", "camper_id"], name: "index_registrations_on_camp_id_and_camper_id", unique: true
    t.index ["camp_id"], name: "index_registrations_on_camp_id"
    t.index ["camper_id"], name: "index_registrations_on_camper_id"
    t.index ["registration_payment_id"], name: "index_registrations_on_registration_payment_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
