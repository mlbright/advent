class CalendarView < ApplicationRecord
  belongs_to :calendar
  belongs_to :user

  validates :day_number, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 24, only_integer: true }
  validates :day_number, uniqueness: { scope: [ :calendar_id, :user_id ] }
  validates :viewed_at, presence: true

  before_validation :set_viewed_at, on: :create

  private

  def set_viewed_at
    self.viewed_at ||= Time.zone.now
  end
end
