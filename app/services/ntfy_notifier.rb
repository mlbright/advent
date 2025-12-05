require "net/http"
require "uri"

class NtfyNotifier
  NTFY_BASE_URL = "https://ntfy.sh".freeze

  def self.notify_login(user, topic:)
    return false if topic.blank?

    message = "User '#{user.email}' signed in to Advent Calendar"
    send_notification(topic: topic, message: message, title: "Advent Calendar Login")
  end

  def self.send_notification(topic:, message:, title: nil, priority: nil, tags: nil)
    if topic.blank?
      Rails.logger.warn "NtfyNotifier: Skipping notification, topic is blank"
      return false
    end

    Rails.logger.info "NtfyNotifier: Sending notification to topic '#{topic}' - #{title}: #{message}"

    uri = URI.parse("#{NTFY_BASE_URL}/#{topic}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 5

    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = message
    request["Title"] = title if title.present?
    request["Priority"] = priority.to_s if priority.present?
    request["Tags"] = Array(tags).join(",") if tags.present?

    response = http.request(request)
    success = response.is_a?(Net::HTTPSuccess)

    if success
      Rails.logger.info "NtfyNotifier: Notification sent successfully to topic '#{topic}'"
    else
      Rails.logger.warn "NtfyNotifier: Failed to send notification to topic '#{topic}' - HTTP #{response.code}: #{response.message}"
    end

    success
  rescue StandardError => e
    Rails.logger.error "NtfyNotifier error: #{e.message}"
    false
  end
end
