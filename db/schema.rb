# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_05_23_070623) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "interactions", id: :serial, force: :cascade do |t|
    t.integer "lgil_code", null: false
    t.string "label", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "slug", null: false
    t.index ["label"], name: "index_interactions_on_label", unique: true
    t.index ["lgil_code"], name: "index_interactions_on_lgil_code", unique: true
  end

  create_table "links", id: :serial, force: :cascade do |t|
    t.integer "local_authority_id", null: false
    t.integer "service_interaction_id", null: false
    t.string "url"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "status"
    t.datetime "link_last_checked", precision: nil
    t.integer "analytics", default: 0, null: false
    t.string "link_errors", default: [], null: false, array: true
    t.string "link_warnings", default: [], null: false, array: true
    t.string "problem_summary"
    t.string "suggested_fix"
    t.boolean "not_provided_by_authority", default: false, null: false
    t.index ["analytics"], name: "index_links_on_analytics"
    t.index ["local_authority_id", "service_interaction_id"], name: "index_links_on_local_authority_id_and_service_interaction_id", unique: true
    t.index ["local_authority_id"], name: "index_links_on_local_authority_id"
    t.index ["service_interaction_id"], name: "index_links_on_service_interaction_id"
    t.index ["status"], name: "index_links_on_status"
    t.index ["url"], name: "index_links_on_url"
  end

  create_table "local_authorities", id: :serial, force: :cascade do |t|
    t.string "gss", null: false
    t.string "homepage_url"
    t.string "name", null: false
    t.string "slug", null: false
    t.string "snac"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "status"
    t.datetime "link_last_checked", precision: nil
    t.integer "parent_local_authority_id"
    t.integer "broken_link_count", default: 0
    t.integer "tier_id"
    t.string "link_errors", default: [], null: false, array: true
    t.string "link_warnings", default: [], null: false, array: true
    t.string "problem_summary"
    t.string "suggested_fix"
    t.string "country_name"
    t.string "local_custodian_code"
    t.datetime "active_end_date", precision: nil
    t.string "active_note"
    t.integer "succeeded_by_local_authority_id"
    t.uuid "content_id", default: -> { "gen_random_uuid()" }
    t.index ["content_id"], name: "index_local_authorities_on_content_id", unique: true
    t.index ["gss"], name: "index_local_authorities_on_gss", unique: true
    t.index ["homepage_url"], name: "index_local_authorities_on_homepage_url"
    t.index ["slug"], name: "index_local_authorities_on_slug", unique: true
    t.index ["snac"], name: "index_local_authorities_on_snac", unique: true
    t.index ["succeeded_by_local_authority_id"], name: "index_local_authorities_on_succeeded_by_local_authority_id"
  end

  create_table "service_interactions", id: :serial, force: :cascade do |t|
    t.integer "service_id"
    t.integer "interaction_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "govuk_slug"
    t.string "govuk_title"
    t.boolean "live"
    t.index ["govuk_slug"], name: "index_service_interactions_on_govuk_slug"
    t.index ["service_id", "interaction_id"], name: "index_service_interactions_on_service_id_and_interaction_id", unique: true
  end

  create_table "service_tiers", id: :serial, force: :cascade do |t|
    t.integer "tier_id", null: false
    t.integer "service_id", null: false
    t.datetime "created_at", precision: nil
    t.index ["service_id", "tier_id"], name: "index_service_tiers_on_service_id_and_tier_id", unique: true
    t.index ["service_id"], name: "index_service_tiers_on_service_id"
    t.index ["tier_id"], name: "index_service_tiers_on_tier_id"
  end

  create_table "services", id: :serial, force: :cascade do |t|
    t.integer "lgsl_code", null: false
    t.string "label", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "slug", null: false
    t.boolean "enabled", default: false, null: false
    t.integer "broken_link_count", default: 0
    t.index ["label"], name: "index_services_on_label", unique: true
    t.index ["lgsl_code"], name: "index_services_on_lgsl_code", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "uid"
    t.string "organisation_slug"
    t.string "organisation_content_id"
    t.text "permissions"
    t.boolean "remotely_signed_out", default: false
    t.boolean "disabled", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  add_foreign_key "links", "local_authorities"
  add_foreign_key "links", "service_interactions"
  add_foreign_key "service_interactions", "interactions"
  add_foreign_key "service_interactions", "services"
  add_foreign_key "service_tiers", "services"
end
