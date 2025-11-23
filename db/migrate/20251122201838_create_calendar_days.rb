class CreateCalendarDays < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_days do |t|
      t.integer :calendar_id, null: false
      t.integer :day_number, null: false

      t.timestamps
    end

    add_index :calendar_days, :calendar_id
    add_index :calendar_days, [ :calendar_id, :day_number ], unique: true
  end
end
