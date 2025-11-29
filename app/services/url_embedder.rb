class UrlEmbedder
  def self.embed(url, element_type = nil)
    return "" if url.blank?

    uri = URI.parse(url)

    case element_type
    when "video"
      embed_video(url, uri)
    when "image"
      embed_image(url)
    else
      # Auto-detect
      if video_url?(url, uri)
        embed_video(url, uri)
      elsif image_url?(url, uri)
        embed_image(url)
      else
        embed_link(url)
      end
    end
  rescue URI::InvalidURIError, ArgumentError
    embed_link(url)
  end

  private

  def self.video_url?(url, uri)
    host = uri.host&.downcase || ""
    host.include?("youtube.com") || host.include?("youtu.be") || host.include?("vimeo.com")
  end

  def self.image_url?(url, uri)
    path = uri.path&.downcase || ""
    path.match?(/\.(jpe?g|png|gif|webp)(\?.*)?$/)
  end

  def self.embed_video(url, uri)
    host = uri.host&.downcase || ""

    if host.include?("youtube.com")
      video_id = extract_youtube_id(url, uri)
      return embed_link(url) unless video_id

      # Extract time parameters (t= or start=) from the original URL
      time_param = extract_youtube_time_param(uri)

      <<~HTML.html_safe
        <div class="embed-container">
          <iframe src="https://www.youtube-nocookie.com/embed/#{video_id}#{time_param}"#{" "}
                  frameborder="0"#{" "}
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"#{" "}
                  allowfullscreen>
          </iframe>
        </div>
      HTML
    elsif host.include?("youtu.be")
      video_id = uri.path.split("/").last&.split("?")&.first
      return embed_link(url) unless video_id

      # Extract time parameters from youtu.be URLs
      time_param = extract_youtube_time_param(uri)

      <<~HTML.html_safe
        <div class="embed-container">
          <iframe src="https://www.youtube-nocookie.com/embed/#{video_id}#{time_param}"#{" "}
                  frameborder="0"#{" "}
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"#{" "}
                  allowfullscreen>
          </iframe>
        </div>
      HTML
    elsif host.include?("vimeo.com")
      video_id = uri.path.split("/").last
      return embed_link(url) unless video_id&.match?(/^\d+$/)

      <<~HTML.html_safe
        <div class="embed-container">
          <iframe src="https://player.vimeo.com/video/#{video_id}"#{" "}
                  frameborder="0"#{" "}
                  allow="autoplay; fullscreen; picture-in-picture"#{" "}
                  allowfullscreen>
          </iframe>
        </div>
      HTML
    else
      embed_link(url)
    end
  end

  def self.extract_youtube_id(url, uri)
    if uri.query
      params = URI.decode_www_form(uri.query).to_h
      return params["v"] if params["v"]
    end

    if uri.path =~ /\/(embed|v)\/([a-zA-Z0-9_-]+)/
      return $2
    end

    nil
  end

  def self.extract_youtube_time_param(uri)
    return "" unless uri.query

    params = URI.decode_www_form(uri.query).to_h

    # Handle both 't' parameter (from share links) and 'start' parameter (embed links)
    time_value = params["t"] || params["start"]
    return "" unless time_value

    # Sanitize: ensure it's only digits and optional 's' suffix
    # YouTube accepts formats like: 123, 123s, 1m30s, 1h2m3s
    if time_value.match?(/^[\dsmh]+$/)
      # Convert to seconds if needed (YouTube embed only accepts 'start' in seconds)
      seconds = parse_youtube_time(time_value)
      "?start=#{seconds}" if seconds
    else
      ""
    end
  end

  def self.parse_youtube_time(time_str)
    return nil if time_str.blank?

    # Remove trailing 's' if present
    time_str = time_str.gsub(/s$/, "")

    # If it's just a number, return it
    return time_str.to_i if time_str.match?(/^\d+$/)

    # Parse time formats like "1h2m3" or "2m30"
    hours = 0
    minutes = 0
    seconds = 0

    if time_str =~ /(\d+)h/
      hours = $1.to_i
    end

    if time_str =~ /(\d+)m/
      minutes = $1.to_i
    end

    # Get remaining seconds after h and m
    remaining = time_str.gsub(/\d+[hm]/, "")
    seconds = remaining.to_i if remaining.match?(/^\d+$/)

    total_seconds = (hours * 3600) + (minutes * 60) + seconds
    (total_seconds > 0) ? total_seconds : nil
  end

  def self.embed_image(url)
    "<img src=\"#{ERB::Util.html_escape(url)}\" class=\"embedded-image\" alt=\"Calendar content image\" style=\"max-width: 100%; height: auto; display: block;\" loading=\"lazy\" />".html_safe
  end

  def self.embed_link(url)
    "<a href=\"#{ERB::Util.html_escape(url)}\" target=\"_blank\" rel=\"noopener noreferrer\">#{ERB::Util.html_escape(url)}</a>".html_safe
  end
end
