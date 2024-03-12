class ChangeEntityLinksPageidNullable < ActiveRecord::Migration[5.2]
  def change
    change_column_null :entity_links, :pageid, true
  end
end
