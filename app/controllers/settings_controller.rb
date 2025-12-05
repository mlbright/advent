class SettingsController < ApplicationController
  before_action :require_admin

  def edit
    @ntfy_topic = current_user.ntfy_topic
  end

  def update
    if current_user.update(ntfy_topic: params[:ntfy_topic])
      redirect_to settings_path, notice: "Settings updated successfully!"
    else
      @ntfy_topic = params[:ntfy_topic]
      flash.now[:alert] = "Failed to update settings"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "You must be an admin to access this page."
    end
  end
end
