class CreateCalendarViews < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_views do |t|
      t.integer :calendar_id, null: false
      t.integer :user_id, null: false
      t.integer :day_number, null: false
      t.datetime :viewed_at, null: false

      t.timestamps
    end

    add_index :calendar_views, [ :calendar_id, :user_id, :day_number ], unique: true, name: "index_calendar_views_on_calendar_user_day"
  end
end
