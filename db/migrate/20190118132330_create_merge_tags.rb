class CreateMergeTags < ActiveRecord::Migration[5.2]
  def change
    create_table :merge_tags do |t|
      t.belongs_to :merge_value, index: true
      t.belongs_to :paragraph, index: true
      t.integer :start_offset
      t.integer :end_offset
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
