require "test_helper"

class UserLoginServiceTest < ActiveSupport::TestCase
  def setup
    @user = users(:homer)
  end

  def test_succeeds_with_valid_credentials
    freeze_time do
      result = UserLoginService.call(params: { email: @user.email, password: "password123" })
      assert result.success?

      data = result.value!
      assert_not_nil data[:access_token]
      assert_not_nil data[:refresh_token]
      assert_not_nil data[:refresh_token_expires_at]

      assert data[:refresh_token_expires_at].future?
      assert_equal @user.id, data[:user][:id]

      @user.reload
      assert_equal @user.refresh_token, data[:refresh_token]
      assert_equal @user.refresh_token_expires_at.round(6), data[:refresh_token_expires_at].round(6)
    end
  end

  def test_fails_when_email_is_missing
    result = UserLoginService.call(params: { email: "", password: "password123" })
    assert result.failure?
    assert_includes result.failure, "Email is required"
  end

  def test_fails_when_password_is_missing
    result = UserLoginService.call(params: { email: @user.email, password: "" })
    assert result.failure?
    assert_includes result.failure, "Password is required"
  end

  def test_fails_with_invalid_password
    result = UserLoginService.call(params: { email: @user.email, password: "wrongpass" })
    assert result.failure?
    assert_equal "Invalid password", result.failure
  end

  def test_fails_with_nonexistent_user
    result = UserLoginService.call(params: { email: "nonexistent@example.com", password: "password123" })
    assert result.failure?
    assert_equal "User not found", result.failure
  end
end
