class CalendarsController < ApplicationController
  before_action :set_calendar, only: [:show, :edit, :update, :destroy, :shuffle]
  before_action :authorize_creator, only: [:edit, :update, :destroy, :shuffle]
  before_action :authorize_viewer, only: [:show]

  def index
    @received_calendars = current_user.received_calendars.includes(:creator).order(year: :desc, created_at: :desc).group_by(&:year)
    @created_calendars = current_user.created_calendars.includes(:recipient).order(year: :desc, created_at: :desc).group_by(&:year)
  end

  def show
    @calendar_days = @calendar.calendar_days.order(:display_position)
  end

  def new
    @calendar = current_user.created_calendars.build(year: Time.zone.now.year)
    @users = User.where.not(id: current_user.id).order(:email)
  end

  def create
    @calendar = current_user.created_calendars.build(calendar_params)

    if @calendar.save
      redirect_to @calendar, notice: "Calendar was successfully created."
    else
      @users = User.where.not(id: current_user.id).order(:email)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @users = User.where.not(id: current_user.id).order(:email)
  end

  def update
    if @calendar.update(calendar_params)
      redirect_to @calendar, notice: "Calendar was successfully updated."
    else
      @users = User.where.not(id: current_user.id).order(:email)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @calendar.destroy
    redirect_to calendars_url, notice: "Calendar was successfully deleted."
  end

  def shuffle
    unless @calendar.can_shuffle?
      redirect_to @calendar, alert: "Shuffling is only allowed until November 30th."
      return
    end

    if @calendar.shuffle_days
      redirect_to @calendar, notice: "Calendar days have been shuffled successfully."
    else
      redirect_to @calendar, alert: "Failed to shuffle calendar days."
    end
  end

  private

  def set_calendar
    @calendar = Calendar.find(params[:id])
  end

  def authorize_creator
    unless @calendar.creator == current_user
      redirect_to calendars_path, alert: "You are not authorized to perform this action."
    end
  end

  def authorize_viewer
    unless @calendar.creator == current_user || @calendar.recipient == current_user
      redirect_to calendars_path, alert: "You are not authorized to view this calendar."
    end
  end

  def calendar_params
    params.require(:calendar).permit(:title, :description, :recipient_id, :year)
  end
end
