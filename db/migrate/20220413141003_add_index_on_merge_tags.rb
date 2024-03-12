class AddIndexOnMergeTags < ActiveRecord::Migration[5.2]
  def change
    add_index :merge_tags, [:merge_value_id, :status], where: "(status = 1)"
  end
end
