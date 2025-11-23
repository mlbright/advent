require "test_helper"

class ContentElementsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get content_elements_create_url
    assert_response :success
  end

  test "should get update" do
    get content_elements_update_url
    assert_response :success
  end

  test "should get destroy" do
    get content_elements_destroy_url
    assert_response :success
  end
end
