require "test_helper"

class CalendarViewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @calendar = calendars(:one)
    @calendar_day = calendar_days(:one)
    log_in_as(@user)
  end

  test "should create calendar view" do
    post calendar_views_url, params: { calendar_view: { calendar_id: @calendar.id, calendar_day_id: @calendar_day.id } }, as: :turbo_stream
    assert_response :success
  end
end
