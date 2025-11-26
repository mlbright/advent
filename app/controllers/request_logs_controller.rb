class RequestLogsController < ApplicationController
  before_action :require_admin

  def index
    @page = params[:page].to_i > 0 ? params[:page].to_i : 1
    per_page = 50
    offset = (@page - 1) * per_page

    @request_logs = RequestLog.includes(:user)
                              .recent
                              .limit(per_page)
                              .offset(offset)

    @total_count = RequestLog.count
    @total_pages = (@total_count.to_f / per_page).ceil
  end

  private

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "You must be an admin to access this page."
    end
  end
end
