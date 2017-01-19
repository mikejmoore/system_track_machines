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

ActiveRecord::Schema.define(version: 20161031204322) do

  create_table "environments", force: :cascade do |t|
    t.integer  "account_id", limit: 4,   null: false
    t.string   "name",       limit: 255, null: false
    t.string   "code",       limit: 255, null: false
    t.string   "category",   limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "environments", ["account_id", "code"], name: "index_environments_on_account_id_and_code", unique: true, using: :btree
  add_index "environments", ["account_id", "name"], name: "index_environments_on_account_id_and_name", unique: true, using: :btree

  create_table "machine_network_interfaces", force: :cascade do |t|
    t.integer "machine_id",  limit: 4
    t.integer "network_id",  limit: 4
    t.string  "mac_address", limit: 255
    t.string  "code",        limit: 255
    t.integer "dhcp",        limit: 4
  end

  create_table "machine_services", force: :cascade do |t|
    t.integer  "machine_id",     limit: 4,   null: false
    t.integer  "service_id",     limit: 4,   null: false
    t.integer  "environment_id", limit: 4,   null: false
    t.string   "ip_address",     limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "machine_services", ["machine_id"], name: "index_machine_services_on_machine_id", using: :btree
  add_index "machine_services", ["service_id"], name: "index_machine_services_on_service_id", using: :btree

  create_table "machine_tags", force: :cascade do |t|
    t.integer "machine_id", limit: 4,   null: false
    t.string  "tag",        limit: 255, null: false
  end

  add_index "machine_tags", ["machine_id", "tag"], name: "index_machine_tags_on_machine_id_and_tag", unique: true, using: :btree

  create_table "machines", force: :cascade do |t|
    t.integer  "account_id",      limit: 4
    t.integer  "network_id",      limit: 4
    t.string   "name",            limit: 255,                         null: false
    t.string   "code",            limit: 255
    t.string   "status",          limit: 255,                         null: false
    t.integer  "environment_id",  limit: 4
    t.string   "ip_address",      limit: 255
    t.string   "os",              limit: 255
    t.string   "dns_name",        limit: 255
    t.string   "brand",           limit: 255
    t.string   "model",           limit: 255
    t.integer  "drive_space",     limit: 4
    t.integer  "drive_speed",     limit: 4
    t.integer  "cpu_speed",       limit: 4
    t.integer  "cpu_count",       limit: 4
    t.integer  "memory",          limit: 4
    t.decimal  "price",                       precision: 8, scale: 2
    t.datetime "purchase_date"
    t.datetime "activation_date"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  create_table "network_cards", force: :cascade do |t|
    t.integer  "machine_id",  limit: 4
    t.integer  "network_id",  limit: 4
    t.string   "ip_address",  limit: 255
    t.string   "mac_address", limit: 255
    t.string   "interface",   limit: 255
    t.string   "brand",       limit: 255
    t.string   "model",       limit: 255
    t.boolean  "ssh_service",             default: false, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "networks", force: :cascade do |t|
    t.integer  "account_id",      limit: 4,                           null: false
    t.string   "name",            limit: 255,                         null: false
    t.string   "code",            limit: 255,                         null: false
    t.string   "status",          limit: 255,                         null: false
    t.string   "address",         limit: 255
    t.string   "mask",            limit: 255
    t.string   "gateway",         limit: 255
    t.string   "broadcast",       limit: 255
    t.decimal  "price",                       precision: 8, scale: 2
    t.datetime "activation_date"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  create_table "networks_environments", id: false, force: :cascade do |t|
    t.integer "network_id",     limit: 4, null: false
    t.integer "environment_id", limit: 4, null: false
  end

  add_index "networks_environments", ["network_id", "environment_id"], name: "index_networks_environments_on_network_id_and_environment_id", unique: true, using: :btree

  create_table "networks_services", id: false, force: :cascade do |t|
    t.integer "network_id",     limit: 4, null: false
    t.integer "service_id",     limit: 4, null: false
    t.integer "environment_id", limit: 4
  end

  add_index "networks_services", ["service_id", "network_id"], name: "index_networks_services_on_service_id_and_network_id", unique: true, using: :btree

  create_table "services", force: :cascade do |t|
    t.integer  "account_id",  limit: 4,     null: false
    t.string   "name",        limit: 255,   null: false
    t.string   "code",        limit: 255,   null: false
    t.string   "description", limit: 255
    t.text     "information", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "services", ["account_id", "code"], name: "index_services_on_account_id_and_code", unique: true, using: :btree

  create_table "services_environments", id: false, force: :cascade do |t|
    t.integer "service_id",     limit: 4, null: false
    t.integer "environment_id", limit: 4, null: false
  end

  add_index "services_environments", ["service_id", "environment_id"], name: "index_services_environments_on_service_id_and_environment_id", unique: true, using: :btree

  create_table "tags", force: :cascade do |t|
    t.integer  "account_id",  limit: 4
    t.string   "object_type", limit: 255, null: false
    t.string   "code",        limit: 255, null: false
    t.string   "name",        limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

end
