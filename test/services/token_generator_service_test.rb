require "test_helper"

class TokenGeneratorServiceTest < ActiveSupport::TestCase
  def test_successful_token_generation
    user_id = 123

    result = TokenGeneratorService.call(params: { user_id: user_id })

    assert result.success?, "Expected success, got failure: #{result.failure}"

    data = result.value!
    assert_equal user_id, data[:user_id]
    assert data[:access_token].present?, "Expected access_token to be present"
    assert data[:refresh_token].present?, "Expected refresh_token to be present"
    assert data[:refresh_token_expires_at].future?, "Expected refresh_token_expires_at to be in the future"

    decoded = JsonWebToken.decode(data[:access_token])
    assert_equal user_id, decoded[:user_id]
  end

  def test_missing_user_id_returns_failure
    result = TokenGeneratorService.call(params: { user_id: nil })

    assert result.failure?, "Expected failure, got success"
    assert_includes result.failure, "UserId is required"
  end
end
