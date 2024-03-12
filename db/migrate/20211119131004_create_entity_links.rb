class CreateEntityLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :entity_links do |t|
      t.belongs_to :link_annotation, index: true

      t.string     :title,        null: false
      t.integer    :pageid,       null: false
      t.text       :first_sentence
      t.integer    :status,       default: 0

      t.boolean :match,           default: false
      t.boolean :later_name,      default: false
      t.boolean :part_of,         default: false
      t.boolean :derivation_of,   default: false

      t.timestamps
    end
  end
end
