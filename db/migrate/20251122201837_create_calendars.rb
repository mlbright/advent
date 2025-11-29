class CreateCalendars < ActiveRecord::Migration[8.1]
  def change
    create_table :calendars do |t|
      t.string :title, null: false
      t.text :description
      t.integer :creator_id, null: false
      t.integer :recipient_id, null: false
      t.integer :year, null: false

      t.timestamps
    end

    add_index :calendars, :creator_id
    add_index :calendars, :recipient_id
    add_index :calendars, [:creator_id, :recipient_id, :year], unique: true, name: "index_calendars_on_creator_recipient_year"
  end
end
