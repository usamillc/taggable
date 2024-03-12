class CreateTaskParagraphs < ActiveRecord::Migration[5.2]
  def change
    create_table :task_paragraphs do |t|
      t.belongs_to :task, index: true
      t.belongs_to :paragraph, index: true
      t.string :body
      t.string :tagged
      t.string :no_tag

      t.timestamps
    end
  end
end
