class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :log_request
  before_action :require_login

  helper_method :current_user, :logged_in?, :viewing_as_creator?

  private

  def log_request
    RequestLog.create(
      ip_address: request.remote_ip,
      path: request.fullpath,
      user: current_user,
      user_agent: request.user_agent,
      request_method: request.method
    )
  rescue => e
    # Don't let logging errors break the application
    Rails.logger.error "Failed to log request: #{e.message}"
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "You must be logged in to access this page."
    end
  end

  def viewing_as_creator?
    @calendar && current_user == @calendar.creator
  end
end
