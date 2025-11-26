module RequestLogsHelper
  def request_method_badge_class(method)
    case method
    when "GET"
      "info"
    when "POST"
      "success"
    when "PUT", "PATCH"
      "warning"
    when "DELETE"
      "danger"
    else
      "secondary"
    end
  end
end
