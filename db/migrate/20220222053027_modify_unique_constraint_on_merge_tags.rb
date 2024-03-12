class ModifyUniqueConstraintOnMergeTags < ActiveRecord::Migration[5.2]
  def change
    remove_index :merge_tags, name: 'index_merge_tags_unique'
    add_index :merge_tags, [:merge_value_id, :paragraph_id, :start_offset, :end_offset, :status],
      unique: true,
      name: 'index_merge_tags_unique'
  end
end
