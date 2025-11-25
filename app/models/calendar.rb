class Calendar < ApplicationRecord
  belongs_to :creator, class_name: "User"
  belongs_to :recipient, class_name: "User"
  has_many :calendar_days, dependent: :destroy
  has_many :calendar_views, dependent: :destroy

  accepts_nested_attributes_for :calendar_days, allow_destroy: true

  validates :title, presence: true
  validates :year, presence: true, numericality: { greater_than_or_equal_to: 2025, only_integer: true }
  validates :creator_id, uniqueness: { scope: [ :recipient_id, :year ], message: "can only create one calendar per recipient per year" }

  after_create :generate_calendar_days
  after_create :shuffle_calendar_days

  def day_unlocked_for?(day_number, user)
    return true if creator == user
    return false unless Time.zone.now.month == 12 && year == Time.zone.now.year
    Time.zone.now.day >= day_number
  end

  def can_shuffle?
    # Allow shuffling until November 30th (inclusive) of the calendar year
    current_date = Time.zone.now.to_date
    deadline = Date.new(year, 11, 30)
    current_date <= deadline
  end

  def shuffle_days
    days = calendar_days.to_a
    return false if days.length < 2

    transaction do
      # Generate shuffled positions (1-24)
      shuffled_positions = (1..24).to_a.shuffle

      # Assign new display positions to each day
      days.each_with_index do |day, index|
        day.update!(display_position: shuffled_positions[index])
      end
    end

    true
  rescue StandardError => e
    Rails.logger.error "Shuffle failed: #{e.message}"
    false
  end

  private

  def generate_calendar_days
    return if calendar_days.any?

    (1..24).each do |day_num|
      calendar_days.create!(day_number: day_num, display_position: day_num)
    end
  end

  def shuffle_calendar_days
    # Shuffle is a no-op on newly created calendars since days are empty
    # This hook exists for potential future use if days are pre-populated
  end
end
