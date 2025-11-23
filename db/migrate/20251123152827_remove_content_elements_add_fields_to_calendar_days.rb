class RemoveContentElementsAddFieldsToCalendarDays < ActiveRecord::Migration[8.1]
  def change
    # Add new fields to calendar_days
    add_column :calendar_days, :content_type, :string # 'image' or 'video'
    add_column :calendar_days, :title, :string
    add_column :calendar_days, :description, :text
    add_column :calendar_days, :url, :string

    # Drop content_elements table
    drop_table :content_elements, if_exists: true
  end
end
