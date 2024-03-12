class CreateMergeValues < ActiveRecord::Migration[5.2]
  def change
    create_table :merge_values do |t|
      t.belongs_to :merge_attribute, index: true
      t.string :value
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
