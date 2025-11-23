require "test_helper"

class CalendarDaysControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get calendar_days_show_url
    assert_response :success
  end

  test "should get edit" do
    get calendar_days_edit_url
    assert_response :success
  end

  test "should get update" do
    get calendar_days_update_url
    assert_response :success
  end
end
