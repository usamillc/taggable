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

ActiveRecord::Schema.define(version: 2022_05_23_131800) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "annotated_entity_links", force: :cascade do |t|
    t.bigint "link_merge_annotation_id"
    t.string "title", null: false
    t.integer "pageid"
    t.text "first_sentence"
    t.integer "status", default: 0
    t.integer "match_count", default: 0
    t.integer "later_name_count", default: 0
    t.integer "part_of_count", default: 0
    t.integer "derivation_of_count", default: 0
    t.boolean "match", default: false
    t.boolean "later_name", default: false
    t.boolean "part_of", default: false
    t.boolean "derivation_of", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link_merge_annotation_id"], name: "index_annotated_entity_links_on_link_merge_annotation_id"
  end

  create_table "annotation_attributes", force: :cascade do |t|
    t.bigint "category_id"
    t.string "name"
    t.string "screenname"
    t.string "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ord"
    t.boolean "deleted", default: false
    t.boolean "linkable", default: true
    t.index ["category_id"], name: "index_annotation_attributes_on_category_id"
    t.index ["ord", "id"], name: "index_annotation_attributes_on_ord_and_id"
  end

  create_table "annotations", force: :cascade do |t|
    t.bigint "annotator_id"
    t.bigint "annotation_attribute_id"
    t.integer "start_offset"
    t.integer "end_offset"
    t.string "value"
    t.boolean "reflected", default: false
    t.boolean "deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "task_paragraph_id"
    t.boolean "dummy", default: false
    t.index ["annotation_attribute_id"], name: "index_annotations_on_annotation_attribute_id"
    t.index ["annotator_id"], name: "index_annotations_on_annotator_id"
    t.index ["task_paragraph_id"], name: "index_annotations_on_task_paragraph_id"
  end

  create_table "annotators", force: :cascade do |t|
    t.string "username"
    t.string "screenname"
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.bigint "organization_id"
    t.boolean "deleted", default: false
    t.index ["organization_id"], name: "index_annotators_on_organization_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "screenname"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "def_link"
    t.integer "status", default: 0
    t.string "ene_id"
  end

  create_table "entity_links", force: :cascade do |t|
    t.bigint "link_annotation_id"
    t.string "title", null: false
    t.integer "pageid"
    t.text "first_sentence"
    t.integer "status", default: 0
    t.boolean "match", default: false
    t.boolean "later_name", default: false
    t.boolean "part_of", default: false
    t.boolean "derivation_of", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link_annotation_id"], name: "index_entity_links_on_link_annotation_id"
  end

  create_table "import_errors", force: :cascade do |t|
    t.string "message"
    t.string "error"
    t.bigint "import_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["import_id"], name: "index_import_errors_on_import_id"
  end

  create_table "imports", force: :cascade do |t|
    t.bigint "category_id"
    t.bigint "annotator_id"
    t.integer "tasks_to_import"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["annotator_id"], name: "index_imports_on_annotator_id"
    t.index ["category_id"], name: "index_imports_on_category_id"
  end

  create_table "link_annotations", force: :cascade do |t|
    t.bigint "link_task_id"
    t.bigint "merge_tag_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link_task_id"], name: "index_link_annotations_on_link_task_id"
    t.index ["merge_tag_id"], name: "index_link_annotations_on_merge_tag_id"
  end

  create_table "link_merge_annotations", force: :cascade do |t|
    t.bigint "link_merge_task_id"
    t.bigint "merge_tag_id"
    t.integer "no_link_count", default: 0
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link_merge_task_id"], name: "index_link_merge_annotations_on_link_merge_task_id"
    t.index ["merge_tag_id"], name: "index_link_merge_annotations_on_merge_tag_id"
  end

  create_table "link_merge_tasks", force: :cascade do |t|
    t.bigint "page_id"
    t.bigint "annotator_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["annotator_id"], name: "index_link_merge_tasks_on_annotator_id"
    t.index ["page_id"], name: "index_link_merge_tasks_on_page_id", unique: true
  end

  create_table "link_tasks", force: :cascade do |t|
    t.bigint "page_id"
    t.bigint "annotator_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["annotator_id"], name: "index_link_tasks_on_annotator_id"
    t.index ["page_id"], name: "index_link_tasks_on_page_id"
  end

  create_table "merge_attributes", force: :cascade do |t|
    t.bigint "merge_task_id"
    t.string "name"
    t.string "screenname"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merge_task_id"], name: "index_merge_attributes_on_merge_task_id"
  end

  create_table "merge_tags", force: :cascade do |t|
    t.bigint "merge_value_id"
    t.bigint "paragraph_id"
    t.integer "start_offset"
    t.integer "end_offset"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merge_value_id", "status"], name: "index_merge_tags_on_merge_value_id_and_status", where: "(status = 1)"
    t.index ["merge_value_id"], name: "index_merge_tags_on_merge_value_id"
    t.index ["paragraph_id"], name: "index_merge_tags_on_paragraph_id"
  end

  create_table "merge_tasks", force: :cascade do |t|
    t.bigint "page_id"
    t.bigint "annotator_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["annotator_id"], name: "index_merge_tasks_on_annotator_id"
    t.index ["page_id"], name: "index_merge_tasks_on_page_id"
  end

  create_table "merge_values", force: :cascade do |t|
    t.bigint "merge_attribute_id"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "annotator_count", default: 0
    t.index ["merge_attribute_id"], name: "index_merge_values_on_merge_attribute_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pages", force: :cascade do |t|
    t.integer "aid"
    t.integer "pageid"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id"
    t.string "version"
    t.index ["category_id"], name: "index_pages_on_category_id"
  end

  create_table "paragraphs", force: :cascade do |t|
    t.bigint "page_id"
    t.string "body"
    t.string "no_tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id"], name: "index_paragraphs_on_page_id"
  end

  create_table "revisions", force: :cascade do |t|
    t.string "action"
    t.boolean "undone", default: false
    t.bigint "annotation_id"
    t.bigint "annotator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "task_id"
    t.index ["annotation_id"], name: "index_revisions_on_annotation_id"
    t.index ["annotator_id"], name: "index_revisions_on_annotator_id"
    t.index ["task_id"], name: "index_revisions_on_task_id"
  end

  create_table "task_paragraphs", force: :cascade do |t|
    t.bigint "task_id"
    t.bigint "paragraph_id"
    t.string "body"
    t.string "tagged"
    t.string "no_tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["paragraph_id"], name: "index_task_paragraphs_on_paragraph_id"
    t.index ["task_id"], name: "index_task_paragraphs_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "page_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id"
    t.bigint "annotator_id"
    t.bigint "import_id"
    t.index ["annotator_id"], name: "index_tasks_on_annotator_id"
    t.index ["import_id"], name: "index_tasks_on_import_id"
    t.index ["organization_id"], name: "index_tasks_on_organization_id"
    t.index ["page_id"], name: "index_tasks_on_page_id"
  end

end
