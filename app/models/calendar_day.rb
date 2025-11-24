require "net/http"
require "uri"

class CalendarDay < ApplicationRecord
  belongs_to :calendar

  has_one_attached :image_file
  has_one_attached :video_file

  attribute :content_type, :string
  enum :content_type, { image: "image", video: "video" }

  validates :day_number, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 24, only_integer: true }
  validates :day_number, uniqueness: { scope: :calendar_id }
  validates :content_type, inclusion: { in: %w[image video] }, allow_nil: true

  # Validate that either URL or file is present
  validate :content_source_present, if: -> { content_type.present? }
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, if: -> { url.present? }

  # Custom file validations
  validate :image_file_validation, if: -> { image_file.attached? }
  validate :video_file_validation, if: -> { video_file.attached? }

  validate :url_accessible, if: -> { url.present? && content_type.present? && !has_attached_file? }

  def date_for_year
    Date.new(calendar.year, 12, day_number)
  end

  def has_content?
    content_type.present? && (url.present? || has_attached_file?)
  end

  def has_attached_file?
    (content_type == "image" && image_file.attached?) || (content_type == "video" && video_file.attached?)
  end

  private

  def content_source_present
    unless url.present? || has_attached_file?
      errors.add(:base, "Please provide either a URL or upload a file")
    end
  end

  def image_file_validation
    return unless image_file.attached?

    # Validate content type
    allowed_types = [ "image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp" ]
    unless allowed_types.include?(image_file.content_type)
      errors.add(:image_file, "must be a JPEG, PNG, GIF, or WEBP image")
    end

    # Validate file size (10MB)
    if image_file.byte_size > 10.megabytes
      errors.add(:image_file, "must be less than 10MB")
    end
  end

  def video_file_validation
    return unless video_file.attached?

    # Validate content type
    allowed_types = [ "video/mp4", "video/quicktime", "video/x-msvideo", "video/webm", "video/ogg" ]
    unless allowed_types.include?(video_file.content_type)
      errors.add(:video_file, "must be an MP4, MOV, AVI, WEBM, or OGG video")
    end

    # Validate file size (100MB)
    if video_file.byte_size > 100.megabytes
      errors.add(:video_file, "must be less than 100MB")
    end
  end

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
