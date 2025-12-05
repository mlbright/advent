class SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create ]

  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      send_login_notification(user)
      redirect_to root_path, notice: "Logged in successfully!"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Logged out successfully!"
  end

  private

  def send_login_notification(user)
    ntfy_topic = User.where(admin: true).where.not(ntfy_topic: [ nil, "" ]).pick(:ntfy_topic)
    return if ntfy_topic.blank?

    NtfyNotifier.notify_login(user, topic: ntfy_topic)
  rescue StandardError => e
    Rails.logger.error "Failed to send login notification: #{e.message}"
  end
end
