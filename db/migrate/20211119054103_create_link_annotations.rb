class CreateLinkAnnotations < ActiveRecord::Migration[5.2]
  def change
    create_table :link_annotations do |t|
      t.belongs_to :link_task, index: true
      t.belongs_to :merge_tag, index: true
      t.integer    :status,    default: 0

      t.timestamps
    end
  end
end
