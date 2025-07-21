require "test_helper"

class Api::V1::AuthControllerTest < ActionDispatch::IntegrationTest
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
    @token = JsonWebToken.encode(user_id: @user.id)
  end

  # --------------------------------------------
  # POST /api/v1/auth/login
  # --------------------------------------------
  def test_login_succeeds_with_valid_credentials
    post "/api/v1/auth/login", params: { email: @user.email, password: "password123" }

    assert_response :success
    json = json_response

    assert_not_nil json["access_token"]
    assert_not_nil json["refresh_token"]
    assert_not_nil json["refresh_token_expires_at"]
    assert_not_nil json["user"]
    assert_not json["user"]["password_digest"]
    assert_equal @user.email, json["user"]["email"]
  end

  def test_login_fails_with_invalid_password
    post "/api/v1/auth/login", params: { email: @user.email, password: "wrongpassword" }

    assert_response :unauthorized
    assert json_response["error"].present?
  end

  def test_login_fails_with_missing_params
    post "/api/v1/auth/login", params: { email: "", password: "" }

    assert_response :unauthorized
    assert json_response["error"].present?
  end

  # --------------------------------------------
  # POST /api/v1/auth/refresh
  # --------------------------------------------
  def test_refresh_with_valid_refresh_token
    post "/api/v1/auth/refresh", headers: auth_header(token: @user.refresh_token)

    assert_response :success
    json = json_response

    assert json["access_token"].present?
    assert json["refresh_token"].present?
    assert json["refresh_token_expires_at"].present?
  end

  def test_refresh_with_invalid_refresh_token
    post "/api/v1/auth/refresh", headers: auth_header(token: SecureRandom.hex(32))

    assert_response :unauthorized

    json = JSON.parse(response.body)
    assert json["error"].present?
  end

  # --------------------------------------------
  # DELETE /api/v1/auth/logout
  # --------------------------------------------
  def test_logout_succeeds_with_valid_token
    delete "/api/v1/auth/logout", headers: auth_header(token: @token)

    assert_response :success
    json = json_response

    assert_equal "Logged out successfully", json["message"]
    @user.reload
    assert_nil @user.refresh_token
    assert_nil @user.refresh_token_expires_at
  end

  def test_logout_fails_with_missing_token
    delete "/api/v1/auth/logout"

    assert_response :unauthorized
    assert json_response["error"].present?
  end

  def test_logout_fails_with_invalid_token
    delete "/api/v1/auth/logout", headers: auth_header(token: SecureRandom.hex(32))

    assert_response :unauthorized
    assert json_response["error"].present?
  end

  private

  def auth_header(token: @token)
    { "Authorization" => "Bearer #{token}" }
  end

  def json_response
    JSON.parse(response.body)
  end
end
