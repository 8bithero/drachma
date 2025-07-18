require "test_helper"

class TokenRefreshServiceTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test@example.com",
      first_name: "Test",
      last_name: "Testler",
      password: "password123",
      password_confirmation: "password123",
      refresh_token: SecureRandom.hex(32),
      refresh_token_expires_at: 1.day.from_now
    )
  end

  def test_succeeds_with_valid_refresh_token
    travel_to Time.current do
      params = { refresh_token: @user.refresh_token }
      result = TokenRefreshService.call(params: params)
      assert result.success?

      data = result.value!
      assert_not_nil data[:access_token]
      assert_not_nil data[:refresh_token]
      assert_not_nil data[:refresh_token_expires_at]

      expected_expiry = 30.days.from_now
      assert_in_delta expected_expiry.to_i, data[:refresh_token_expires_at].to_i, 2

      @user.reload
      assert_equal @user.refresh_token, data[:refresh_token]
      assert_equal @user.refresh_token_expires_at, data[:refresh_token_expires_at]
    end
  end

  def test_fails_with_no_refresh_token
    result = TokenRefreshService.call(params: { refresh_token: nil })

    assert result.failure?
    assert_includes result.failure, "Refresh token is required"
  end

  def test_fails_with_expired_refresh_token
    @user.update_columns(refresh_token_expires_at: 1.day.ago)
    result = TokenRefreshService.call(params: { refresh_token: @user.refresh_token })

    assert result.failure?
    assert_equal "Token has expired", result.failure
  end

  def test_fails_with_invalid_refresh_token
    invalid_token = SecureRandom.hex(32)
    result = TokenRefreshService.call(params: { refresh_token: invalid_token })

    assert result.failure?
    assert_includes result.failure, "Invalid token"
  end
end
