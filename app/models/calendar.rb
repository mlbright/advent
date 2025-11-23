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

  def day_unlocked_for?(day_number, user)
    return true if creator == user
    return false unless Time.zone.now.month == 12 && year == Time.zone.now.year
    Time.zone.now.day >= day_number
  end

  private

  def generate_calendar_days
    return if calendar_days.any?

    (1..24).each do |day_num|
      calendar_days.create!(day_number: day_num)
    end
  end
end
