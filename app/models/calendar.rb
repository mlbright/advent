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
    return if days.length < 2

    transaction do
      # Create a mapping of day_number to content
      day_contents = {}
      days.each do |day|
        day_contents[day.day_number] = {
          content_type: day.content_type,
          title: day.title,
          description: day.description,
          url: day.url,
          image_blob: day.image_file.attached? ? day.image_file.blob : nil,
          video_blob: day.video_file.attached? ? day.video_file.blob : nil
        }
      end

      # Generate shuffled day numbers
      shuffled_numbers = (1..24).to_a.shuffle

      # Apply shuffled content to days
      days.each_with_index do |day, index|
        content = day_contents[shuffled_numbers[index]]
        
        # Detach existing files
        day.image_file.detach if day.image_file.attached?
        day.video_file.detach if day.video_file.attached?
        
        # Update with shuffled content
        day.update!(
          content_type: content[:content_type],
          title: content[:title],
          description: content[:description],
          url: content[:url]
        )
        
        # Attach files
        day.image_file.attach(content[:image_blob]) if content[:image_blob]
        day.video_file.attach(content[:video_blob]) if content[:video_blob]
      end
    end
  end

  private

  def generate_calendar_days
    return if calendar_days.any?

    (1..24).each do |day_num|
      calendar_days.create!(day_number: day_num)
    end
  end

  def shuffle_calendar_days
    # Shuffle is a no-op on newly created calendars since days are empty
    # This hook exists for potential future use if days are pre-populated
  end
end
