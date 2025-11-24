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

      <<~HTML.html_safe
        <div class="embed-container">
          <iframe src="https://www.youtube-nocookie.com/embed/#{video_id}"#{' '}
                  frameborder="0"#{' '}
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"#{' '}
                  allowfullscreen>
          </iframe>
        </div>
      HTML
    elsif host.include?("youtu.be")
      video_id = uri.path.split("/").last
      return embed_link(url) unless video_id

      <<~HTML.html_safe
        <div class="embed-container">
          <iframe src="https://www.youtube-nocookie.com/embed/#{video_id}"#{' '}
                  frameborder="0"#{' '}
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"#{' '}
                  allowfullscreen>
          </iframe>
        </div>
      HTML
    elsif host.include?("vimeo.com")
      video_id = uri.path.split("/").last
      return embed_link(url) unless video_id&.match?(/^\d+$/)

      <<~HTML.html_safe
        <div class="embed-container">
          <iframe src="https://player.vimeo.com/video/#{video_id}"#{' '}
                  frameborder="0"#{' '}
                  allow="autoplay; fullscreen; picture-in-picture"#{' '}
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

  def self.embed_image(url)
    "<img src=\"#{ERB::Util.html_escape(url)}\" class=\"embedded-image\" alt=\"Calendar content image\" style=\"max-width: 100%; height: auto; display: block;\" loading=\"lazy\" />".html_safe
  end

  def self.embed_link(url)
    "<a href=\"#{ERB::Util.html_escape(url)}\" target=\"_blank\" rel=\"noopener noreferrer\">#{ERB::Util.html_escape(url)}</a>".html_safe
  end
end
