class CalendarDay < ApplicationRecord
  belongs_to :calendar
  has_many :content_elements, -> { order(:position) }, dependent: :destroy

  accepts_nested_attributes_for :content_elements, allow_destroy: true

  validates :day_number, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 24, only_integer: true }
  validates :day_number, uniqueness: { scope: :calendar_id }

  def date_for_year
    Date.new(calendar.year, 12, day_number)
  end
end
