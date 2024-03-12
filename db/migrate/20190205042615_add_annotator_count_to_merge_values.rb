class AddAnnotatorCountToMergeValues < ActiveRecord::Migration[5.2]
  def change
    add_column :merge_values, :annotator_count, :integer, default: 0
    MergeValue.update_all(annotator_count: 1)
  end
end
