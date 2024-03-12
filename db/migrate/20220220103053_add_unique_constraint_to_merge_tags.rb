class AddUniqueConstraintToMergeTags < ActiveRecord::Migration[5.2]
  def change
    add_index :merge_tags, [:merge_value_id, :paragraph_id, :start_offset, :end_offset],
      unique: true,
      name: 'index_merge_tags_unique'
  end
end
