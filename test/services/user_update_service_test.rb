require "test_helper"

class UserUpdateServiceTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Test",
      last_name: "Testler",
      refresh_token: SecureRandom.hex(32),
      refresh_token_expires_at: 5.days.from_now
    )
  end

  def test_succeeds_when_params_valid
    result = UserUpdateService.call(params: {
      user: @user,
      first_name: "New",
      last_name: "NewTwo",
      email: "new@example.com",
      refresh_token: SecureRandom.hex(32),
      refresh_token_expires_at: 30.days.from_now
    })

    assert result.success?

    data = result.value!
    assert_equal @user, data[:user]
    assert_includes data[:updated_attributes], :first_name
    assert_includes data[:updated_attributes], :last_name
    assert_includes data[:updated_attributes], :email
    assert_includes data[:updated_attributes], :refresh_token
    assert_includes data[:updated_attributes], :refresh_token_expires_at

    @user.reload
    assert_equal "New", @user.first_name
  end

  def test_fails_when_params_invalid
    result = UserUpdateService.call(params: {
      user: @user,
      email: "invalid-email"
    })

    assert result.failure?
    assert_includes result.failure, "Email is invalid"
  end

  def test_fails_when_user_is_nil
    result = UserUpdateService.call(params: { first_name: "Oopsy" })
    assert result.failure?, "Expected failure, got success"
    assert_includes result.failure, "User is required"
  end

  def test_filters_out_blank_nil_and_invalid_values
    result = UserUpdateService.call(params: {
      user: @user,
      first_name: "New",
      last_name: "",
      email: nil,
      password: "AGoodNewPassword!",
      sneaky: "Value"
    })

    assert result.success?
    data = result.value!

    assert_includes data[:updated_attributes], :first_name
    assert_not_includes data[:updated_attributes], :last_name
    assert_not_includes data[:updated_attributes], :email
    assert_not_includes data[:updated_attributes], :password
    assert_not_includes data[:updated_attributes], :sneaky

    @user.reload
    assert_equal "New", @user.first_name
    assert_equal "Testler", @user.last_name
    assert_equal "test@example.com", @user.email
  end
end
