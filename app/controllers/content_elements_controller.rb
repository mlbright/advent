class ContentElementsController < ApplicationController
  before_action :set_content_element, only: [ :update, :destroy ]
  before_action :authorize_creator

  def create
    @calendar_day = CalendarDay.find(params[:content_element][:calendar_day_id])
    @content_element = @calendar_day.content_elements.build(content_element_params)

    if @content_element.save
      redirect_to edit_calendar_calendar_day_path(@calendar_day.calendar, @calendar_day.day_number), notice: "Element was successfully added."
    else
      redirect_to edit_calendar_calendar_day_path(@calendar_day.calendar, @calendar_day.day_number), alert: @content_element.errors.full_messages.join(", ")
    end
  end

  def update
    if @content_element.update(content_element_params)
      redirect_to edit_calendar_calendar_day_path(@content_element.calendar_day.calendar, @content_element.calendar_day.day_number), notice: "Element was successfully updated."
    else
      redirect_to edit_calendar_calendar_day_path(@content_element.calendar_day.calendar, @content_element.calendar_day.day_number), alert: @content_element.errors.full_messages.join(", ")
    end
  end

  def destroy
    calendar = @content_element.calendar_day.calendar
    day_number = @content_element.calendar_day.day_number
    @content_element.destroy
    redirect_to edit_calendar_calendar_day_path(calendar, day_number), notice: "Element was successfully deleted."
  end

  private

  def set_content_element
    @content_element = ContentElement.find(params[:id])
  end

  def authorize_creator
    calendar = @content_element&.calendar_day&.calendar || CalendarDay.find(params[:content_element][:calendar_day_id]).calendar
    unless calendar.creator == current_user
      redirect_to calendars_path, alert: "You are not authorized to perform this action."
    end
  end

  def content_element_params
    params.require(:content_element).permit(:element_type, :text_content, :url, :description, :position)
  end
end
