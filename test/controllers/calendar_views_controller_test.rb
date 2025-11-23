require "test_helper"

class CalendarViewsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get calendar_views_create_url
    assert_response :success
  end
end
