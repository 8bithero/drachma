require "test_helper"

class UserUpdateServiceTest < ActiveSupport::TestCase
  def setup
    @user = users(:homer)
  end

  def test_succeeds_when_params_valid
    result = UserUpdateService.call(params: {
      user: @user,
      first_name: "Max",
      last_name: "Powers",
      email: "max@powers.com",
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
    assert_equal "Max", @user.first_name
  end

  def test_nullable_attrs_allow_nil
    result = UserUpdateService.call(params: {
      user: @user,
      refresh_token: nil,
      refresh_token_expires_at: nil
    })

    assert result.success?

    data = result.value!
    assert_includes data[:updated_attributes], :refresh_token
    assert_includes data[:updated_attributes], :refresh_token_expires_at

    @user.reload
    assert_nil @user.refresh_token
    assert_nil @user.refresh_token_expires_at
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

  def test_ignores_blank_and_unallowed_regular_attributes
    result = UserUpdateService.call(params: {
      user: @user,
      first_name: "Max",
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
    assert_equal "Max", @user.first_name
    assert_equal "Simpson", @user.last_name
    assert_equal "homer@springfield.com", @user.email
  end
end
