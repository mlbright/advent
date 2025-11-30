require "test_helper"

class CalendarDaysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @calendar = calendars(:one)
    @calendar_day = calendar_days(:one)
    log_in_as(@user)
  end

  test "should get show" do
    get calendar_calendar_day_url(@calendar, @calendar_day.day_number)
    assert_response :success
  end

  test "should get edit" do
    get edit_calendar_calendar_day_url(@calendar, @calendar_day.day_number)
    assert_response :success
  end

  test "should update calendar day" do
    patch calendar_calendar_day_url(@calendar, @calendar_day.day_number), params: { calendar_day: { title: "Updated Day" } }
    assert_redirected_to calendar_calendar_day_url(@calendar, @calendar_day.day_number)
  end
end
