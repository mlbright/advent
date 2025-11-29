require "test_helper"

class UsersAdminTest < ActionDispatch::IntegrationTest
  self.use_transactional_tests = true

  setup do
    # Create fresh users for each test
    @admin_user = User.create!(
      email: "admin@example.org",
      password: "password",
      password_confirmation: "password",
      admin: true
    )
    @regular_user = User.create!(
      email: "normal@example.org",
      password: "password",
      password_confirmation: "password",
      admin: false
    )
  end

  test "non-admin cannot set admin flag via params when creating user" do
    # Log in as regular user (note: require_admin filter will redirect non-admins,
    # but we need to test the strong params layer as defense in depth)
    # Since the create action requires admin, we'll test that a non-admin is redirected
    post login_path, params: { email: @regular_user.email, password: "password" }

    # Non-admin should be redirected when trying to access user creation
    post users_path, params: {
      user: {
        email: "newuser@example.org",
        password: "password",
        password_confirmation: "password",
        admin: "1"
      }
    }

    # Should be redirected (not allowed)
    assert_response :redirect
    follow_redirect!

    # User should not have been created
    assert_nil User.find_by(email: "newuser@example.org")
  end

  test "admin can set admin flag via params when creating user" do
    # Log in as admin
    post login_path, params: { email: @admin_user.email, password: "password" }

    assert_difference -> { User.count }, 1 do
      post users_path, params: {
        user: {
          email: "newadmin@example.org",
          password: "password",
          password_confirmation: "password",
          admin: "1"
        }
      }
    end

    created_user = User.find_by(email: "newadmin@example.org")
    assert created_user.present?, "User should have been created"
    assert created_user.admin?, "User should be an admin"
  end

  test "admin creating non-admin user works correctly" do
    # Log in as admin
    post login_path, params: { email: @admin_user.email, password: "password" }

    assert_difference -> { User.count }, 1 do
      post users_path, params: {
        user: {
          email: "regularuser@example.org",
          password: "password",
          password_confirmation: "password",
          admin: "0"
        }
      }
    end

    created_user = User.find_by(email: "regularuser@example.org")
    assert created_user.present?, "User should have been created"
    assert_not created_user.admin?, "User should not be an admin"
  end

  test "admin creating user without admin param defaults to non-admin" do
    # Log in as admin
    post login_path, params: { email: @admin_user.email, password: "password" }

    assert_difference -> { User.count }, 1 do
      post users_path, params: {
        user: {
          email: "defaultuser@example.org",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    created_user = User.find_by(email: "defaultuser@example.org")
    assert created_user.present?, "User should have been created"
    assert_not created_user.admin?, "User should default to non-admin"
  end
end
