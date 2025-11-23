class CalendarDay < ApplicationRecord
  belongs_to :calendar

  attribute :content_type, :string
  enum :content_type, { image: "image", video: "video" }

  validates :day_number, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 24, only_integer: true }
  validates :day_number, uniqueness: { scope: :calendar_id }
  validates :content_type, inclusion: { in: %w[image video] }, allow_nil: true
  validates :url, presence: true, if: -> { content_type.present? }
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, if: -> { url.present? }

  validate :url_accessible, if: -> { url.present? && content_type.present? }

  def date_for_year
    Date.new(calendar.year, 12, day_number)
  end

  def has_content?
    content_type.present? && url.present?
  end

  private

  def url_accessible
    uri = URI.parse(url)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 5) do |http|
      http.head(uri.path.present? ? uri.path : "/")
    end

    unless response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
      errors.add(:url, "is not accessible (HTTP #{response.code})")
    end
  rescue StandardError => e
    errors.add(:url, "could not be validated (#{e.message})")
  end
end
