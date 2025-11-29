require "net/http"
require "uri"

class CalendarDay < ApplicationRecord
  belongs_to :calendar

  has_one_attached :image_file
  has_one_attached :video_file

  attribute :content_type, :string
  enum :content_type, {image: "image", video: "video"}

  validates :day_number, presence: true, numericality: {greater_than_or_equal_to: 1, less_than_or_equal_to: 24, only_integer: true}
  validates :day_number, uniqueness: {scope: :calendar_id}
  validates :content_type, inclusion: {in: %w[image video]}, allow_nil: true

  # Validate that only one content source is present (but allow none)
  validate :only_one_content_source
  validates :url, format: {with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL"}, if: -> { url.present? }

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

  def swap_with(other_day)
    return false if other_day.nil? || other_day.calendar_id != calendar_id

    transaction do
      # Store attributes from both days
      self_attrs = {
        content_type: content_type,
        title: title,
        description: description,
        url: url
      }

      other_attrs = {
        content_type: other_day.content_type,
        title: other_day.title,
        description: other_day.description,
        url: other_day.url
      }

      # Handle attached files by creating temporary references
      self_image = image_file.attached? ? image_file.blob : nil
      self_video = video_file.attached? ? video_file.blob : nil
      other_image = other_day.image_file.attached? ? other_day.image_file.blob : nil
      other_video = other_day.video_file.attached? ? other_day.video_file.blob : nil

      # Detach all files
      image_file.detach if image_file.attached?
      video_file.detach if video_file.attached?
      other_day.image_file.detach if other_day.image_file.attached?
      other_day.video_file.detach if other_day.video_file.attached?

      # Update attributes
      update!(other_attrs)
      other_day.update!(self_attrs)

      # Reattach files to swapped days
      image_file.attach(other_image) if other_image
      video_file.attach(other_video) if other_video
      other_day.image_file.attach(self_image) if self_image
      other_day.video_file.attach(self_video) if self_video
    end

    true
  rescue => e
    Rails.logger.error "Swap failed: #{e.message}"
    false
  end

  private

  def only_one_content_source
    sources = []
    sources << "URL" if url.present? && !url.blank?
    sources << "image upload" if image_file.attached?
    sources << "video upload" if video_file.attached?

    # Only validate if we actually have multiple sources
    # Skip if we're in the process of updating (sources might be transitioning)
    if sources.length > 1
      errors.add(:base, "You can only have one content source. Please use either a URL, an image upload, or a video upload - not multiple.")
    end
  end

  def image_file_validation
    return unless image_file.attached?

    # Validate content type
    allowed_types = ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"]
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
    allowed_types = ["video/mp4", "video/quicktime", "video/x-msvideo", "video/webm", "video/ogg"]
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
  rescue => e
    errors.add(:url, "could not be validated (#{e.message})")
  end
end
