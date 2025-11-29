class CalendarDaysController < ApplicationController
  before_action :set_calendar
  before_action :set_calendar_day
  before_action :authorize_viewer, only: [ :show ]
  before_action :authorize_creator, only: [ :edit, :update, :delete_attachment, :swap_initiate, :swap_complete ]
  before_action :check_day_unlocked, only: [ :show ]

  def show
    # Record the view if recipient is viewing
    if @calendar.recipient == current_user
      CalendarView.find_or_create_by(
        calendar: @calendar,
        user: current_user,
        day_number: @day.day_number
      )
    end
  end

  def edit
  end

  def update
    # Auto-correct content_type if a file is uploaded that doesn't match
    if params[:calendar_day][:image_file].present?
      params[:calendar_day][:content_type] = "image"
    elsif params[:calendar_day][:video_file].present?
      params[:calendar_day][:content_type] = "video"
    end

    # Only purge opposite-type attachments if NOT uploading a new file in this request
    if params[:calendar_day][:content_type] == "image" && @day.video_file.attached? && !params[:calendar_day][:image_file].present?
      @day.video_file.purge
    elsif params[:calendar_day][:content_type] == "video" && @day.image_file.attached? && !params[:calendar_day][:video_file].present?
      @day.image_file.purge
    end

    if @day.update(calendar_day_params)
      redirect_to calendar_calendar_day_path(@calendar, @day.day_number), notice: "Day was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def delete_attachment
    attachment_type = params[:attachment_type]

    if attachment_type == "image" && @day.image_file.attached?
      @day.image_file.purge
      flash[:notice] = "Image deleted successfully."
    elsif attachment_type == "video" && @day.video_file.attached?
      @day.video_file.purge
      flash[:notice] = "Video deleted successfully."
    else
      flash[:alert] = "No attachment found to delete."
    end

    redirect_to edit_calendar_calendar_day_path(@calendar, @day.day_number), status: :see_other
  end

  def swap_initiate
    @other_days = @calendar.calendar_days.where.not(day_number: @day.day_number).order(:day_number)
  end

  def swap_complete
    target_day_number = params[:target_day_number].to_i
    target_day = @calendar.calendar_days.find_by(day_number: target_day_number)

    if target_day.nil?
      redirect_to calendar_path(@calendar), alert: "Invalid target day selected."
      return
    end

    if target_day.day_number == @day.day_number
      redirect_to calendar_path(@calendar), alert: "Cannot swap a day with itself."
      return
    end

    if @day.swap_with(target_day)
      redirect_to calendar_path(@calendar), notice: "Successfully swapped Day #{@day.day_number} with Day #{target_day.day_number}."
    else
      redirect_to calendar_path(@calendar), alert: "Failed to swap days. Please try again."
    end
  end

  private

  def set_calendar
    @calendar = Calendar.where(
      "creator_id = ? OR recipient_id = ?",
      current_user.id,
      current_user.id
    ).find(params[:calendar_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to calendars_path, alert: "Calendar not found or you don't have access to it."
  end

  def set_calendar_day
    @day = @calendar.calendar_days.find_by!(day_number: params[:day_number])
  end

  def authorize_viewer
    unless @calendar.creator == current_user || @calendar.recipient == current_user
      redirect_to calendars_path, alert: "You are not authorized to view this day."
    end
  end

  def authorize_creator
    unless @calendar.creator == current_user
      redirect_to calendars_path, alert: "You are not authorized to edit this day."
    end
  end

  def check_day_unlocked
    unless @calendar.day_unlocked_for?(@day.day_number, current_user)
      redirect_to calendar_path(@calendar), alert: "This day is not yet unlocked."
    end
  end

  def calendar_day_params
    params.require(:calendar_day).permit(:content_type, :title, :description, :url, :image_file, :video_file)
  end
end
