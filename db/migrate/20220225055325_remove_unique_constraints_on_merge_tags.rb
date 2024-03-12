class RemoveUniqueConstraintsOnMergeTags < ActiveRecord::Migration[5.2]
  def change
    remove_index :merge_tags, name: 'index_merge_tags_unique'
  end
end
