class RequestLogsController < ApplicationController
  before_action :require_admin

  def index
    @page = (params[:page].to_i > 0) ? params[:page].to_i : 1
    @filter = params[:filter] || "unauthenticated"
    per_page = 50
    offset = (@page - 1) * per_page

    base_query = RequestLog.includes(:user).recent

    @request_logs = case @filter
    when "authenticated"
      base_query.authenticated
    when "all"
      base_query
    else # "unauthenticated" is the default
      base_query.unauthenticated
    end

    @total_count = @request_logs.count
    @request_logs = @request_logs.limit(per_page).offset(offset)
    @total_pages = (@total_count.to_f / per_page).ceil
  end

  private

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "You must be an admin to access this page."
    end
  end
end
