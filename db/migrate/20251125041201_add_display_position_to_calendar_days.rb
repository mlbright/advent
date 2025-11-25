class AddDisplayPositionToCalendarDays < ActiveRecord::Migration[8.1]
  def change
    add_column :calendar_days, :display_position, :integer

    # Set initial display_position to match day_number for existing records
    reversible do |dir|
      dir.up do
        CalendarDay.find_each do |day|
          day.update_column(:display_position, day.day_number)
        end
      end
    end
  end
end
