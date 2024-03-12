class CreateLinkMergeAnnotations < ActiveRecord::Migration[5.2]
  def change
    create_table :link_merge_annotations do |t|
      t.belongs_to :link_merge_task, index: true
      t.belongs_to :merge_tag,       index: true
      t.integer    :no_link_count,   default: 0
      t.integer    :status,          default: 0

      t.timestamps
    end
  end
end
