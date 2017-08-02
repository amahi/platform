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

ActiveRecord::Schema.define(version: 20170720052348) do

  create_table "app_dependencies", force: :cascade do |t|
    t.integer  "app_id"
    t.integer  "dependency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "apps", force: :cascade do |t|
    t.boolean  "installed"
    t.string   "name"
    t.string   "screenshot_url"
    t.string   "identifier"
    t.text     "description"
    t.string   "version"
    t.string   "app_url"
    t.string   "logo_url"
    t.integer  "webapp_id"
    t.string   "status"
    t.boolean  "show_in_dashboard",    default: true
    t.string   "forum_url"
    t.integer  "theme_id"
    t.text     "special_instructions"
    t.integer  "db_id"
    t.integer  "server_id"
    t.integer  "share_id"
    t.string   "initial_user"
    t.string   "initial_password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "plugin_id"
  end

  create_table "cap_accesses", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "share_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cap_writers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "share_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "containers", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "options",    null: false
    t.string   "kind",       null: false
    t.integer  "app_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dbs", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dns_aliases", force: :cascade do |t|
    t.string "name",    default: "", null: false
    t.string "address", default: "", null: false
  end

  create_table "firewalls", force: :cascade do |t|
    t.string   "kind",       default: ""
    t.boolean  "state",      default: true
    t.string   "ip",         default: ""
    t.string   "protocol",   default: "both"
    t.string   "range",      default: ""
    t.string   "mac",        default: ""
    t.string   "url",        default: ""
    t.string   "comment",    default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hosts", force: :cascade do |t|
    t.string "name",                 null: false
    t.string "mac",     default: ""
    t.string "address"
  end

  create_table "plugins", force: :cascade do |t|
    t.string   "name"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "servers", force: :cascade do |t|
    t.string   "name",                         null: false
    t.string   "comment",       default: ""
    t.string   "pidfile"
    t.string   "start"
    t.string   "stop"
    t.boolean  "monitored",     default: true
    t.boolean  "start_at_boot", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.string "kind",  default: "general"
  end

  create_table "shares", force: :cascade do |t|
    t.string   "name"
    t.string   "path"
    t.boolean  "rdonly"
    t.boolean  "visible"
    t.boolean  "everyone",         default: true
    t.string   "tags",             default: ""
    t.text     "extras"
    t.integer  "disk_pool_copies", default: 0
    t.boolean  "guest_access",     default: false
    t.boolean  "guest_writeable",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "testapps", force: :cascade do |t|
    t.string   "identifier"
    t.text     "installer"
    t.text     "uninstaller"
    t.text     "info"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "themes", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "css",  default: "", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "login",                         null: false
    t.string   "name"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "login_count",       default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.boolean  "admin"
    t.text     "public_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "webapp_aliases", force: :cascade do |t|
    t.string   "name"
    t.integer  "webapp_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "webapps", force: :cascade do |t|
    t.string   "name",                           null: false
    t.string   "path",           default: ""
    t.string   "kind",           default: ""
    t.string   "aliases",        default: ""
    t.string   "fname",          default: ""
    t.boolean  "deletable",      default: true
    t.boolean  "login_required", default: false
    t.integer  "dns_alias_id"
    t.text     "custom_options"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
