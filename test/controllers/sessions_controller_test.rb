require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get login_url
    assert_response :success
  end

  test "should create session" do
    post login_url, params: { email: "testuser1@example.com", password: "password" }
    assert_redirected_to root_url
    assert session[:user_id]
  end

  test "should destroy session" do
    log_in_as(users(:one))
    delete logout_url
    assert_redirected_to login_url
    assert_nil session[:user_id]
  end
end
