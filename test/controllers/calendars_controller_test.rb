require "test_helper"

class CalendarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @calendar = calendars(:one)
    log_in_as(@user)
  end

  test "should get index" do
    get calendars_url
    assert_response :success
  end

  test "should get show" do
    get calendar_url(@calendar)
    assert_response :success
  end

  test "should get new" do
    get new_calendar_url
    assert_response :success
  end

  test "should create calendar" do
    assert_difference("Calendar.count") do
      post calendars_url, params: { calendar: { title: "Test Calendar", description: "Test description", recipient_id: users(:two).id, year: 2026 } }
    end
    assert_redirected_to calendar_url(Calendar.last)
  end

  test "should get edit" do
    get edit_calendar_url(@calendar)
    assert_response :success
  end

  test "should update calendar" do
    patch calendar_url(@calendar), params: { calendar: { title: "Updated Title" } }
    assert_redirected_to calendar_url(@calendar)
  end
end
