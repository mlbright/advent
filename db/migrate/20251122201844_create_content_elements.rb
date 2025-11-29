class CreateContentElements < ActiveRecord::Migration[8.1]
  def change
    create_table :content_elements do |t|
      t.integer :calendar_day_id, null: false
      t.string :element_type, null: false
      t.integer :position, null: false
      t.text :text_content
      t.string :url
      t.text :description

      t.timestamps
    end

    add_index :content_elements, :calendar_day_id
    add_index :content_elements, [:calendar_day_id, :position]
  end
end
