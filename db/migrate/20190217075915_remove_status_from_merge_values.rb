class RemoveStatusFromMergeValues < ActiveRecord::Migration[5.2]
  def change
    remove_column :merge_values, :status
  end
end
