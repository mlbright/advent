class CalendarDaysController < ApplicationController
  before_action :set_calendar
  before_action :set_calendar_day
  before_action :authorize_viewer, only: [ :show ]
  before_action :authorize_creator, only: [ :edit, :update ]
  before_action :check_day_unlocked, only: [ :show ]

  def show
    @content_elements = @day.content_elements.order(:position)

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
    @day.content_elements.build if @day.content_elements.empty?
  end

  def update
    if @day.update(calendar_day_params)
      redirect_to calendar_calendar_day_path(@calendar, @day.day_number), notice: "Day was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_calendar
    @calendar = Calendar.find(params[:calendar_id])
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
    params.require(:calendar_day).permit(
      content_elements_attributes: [ :id, :element_type, :text_content, :url, :description, :position, :_destroy ]
    )
  end
end
