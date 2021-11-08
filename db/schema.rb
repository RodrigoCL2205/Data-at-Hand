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

ActiveRecord::Schema.define(version: 2021_11_08_194138) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.string "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "rejection_reasons", force: :cascade do |t|
    t.string "codigo"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "rejections", force: :cascade do |t|
    t.bigint "sample_id", null: false
    t.bigint "rejection_reason_id", null: false
    t.text "comment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["rejection_reason_id"], name: "index_rejections_on_rejection_reason_id"
    t.index ["sample_id"], name: "index_rejections_on_sample_id"
  end

  create_table "samples", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.integer "sample_number"
    t.string "programa"
    t.string "matriz"
    t.string "subgrupo"
    t.string "produto"
    t.string "rg"
    t.string "area_analitica"
    t.string "objetivo_amostra"
    t.boolean "liberada"
    t.boolean "latente"
    t.boolean "descartada"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status"
    t.date "data_recepcao"
    t.date "data_liberacao"
    t.date "data_descarte"
    t.index ["client_id"], name: "index_samples_on_client_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "rejections", "rejection_reasons"
  add_foreign_key "rejections", "samples"
  add_foreign_key "samples", "clients"
end
