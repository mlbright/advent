class ContentElement < ApplicationRecord
  belongs_to :calendar_day

  enum :element_type, {text: "text", image: "image", video: "video"}

  validates :element_type, presence: true, inclusion: {in: %w[text image video]}
  validates :position, presence: true, numericality: {only_integer: true, greater_than: 0}
  validates :text_content, presence: true, if: -> { element_type == "text" }
  validates :url, presence: true, if: -> { element_type.in?(["image", "video"]) }
  validates :url, format: {with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL"}, if: -> { url.present? }

  validate :url_accessible, if: -> { url.present? && element_type.in?(["image", "video"]) }

  before_create :set_position

  private

  def set_position
    return if position.present?
    max_position = calendar_day.content_elements.maximum(:position) || 0
    self.position = max_position + 1
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
