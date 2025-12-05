require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @regular_user = users(:one)
  end

  test "should redirect non-admin from settings page" do
    log_in_as(@regular_user)
    get settings_url
    assert_redirected_to root_path
    assert_equal "You must be an admin to access this page.", flash[:alert]
  end

  test "should get edit for admin" do
    log_in_as(@admin)
    get settings_url
    assert_response :success
    assert_select "h1", "Settings"
  end

  test "should update ntfy topic" do
    log_in_as(@admin)
    patch settings_url, params: { ntfy_topic: "new-topic-name" }
    assert_redirected_to settings_path
    assert_equal "Settings updated successfully!", flash[:notice]
    @admin.reload
    assert_equal "new-topic-name", @admin.ntfy_topic
  end

  test "should allow clearing ntfy topic" do
    log_in_as(@admin)
    patch settings_url, params: { ntfy_topic: "" }
    assert_redirected_to settings_path
    @admin.reload
    assert_equal "", @admin.ntfy_topic
  end

  test "non-admin cannot update settings" do
    log_in_as(@regular_user)
    patch settings_url, params: { ntfy_topic: "hacker-topic" }
    assert_redirected_to root_path
    @regular_user.reload
    assert_nil @regular_user.ntfy_topic
  end
end
