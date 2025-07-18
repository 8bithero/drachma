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
    post "/api/v1/auth/refresh", headers: { "Authorization" => "Bearer #{@user.refresh_token}" }

    assert_response :success
    json = json_response

    assert json["access_token"].present?
    assert json["refresh_token"].present?
    assert json["refresh_token_expires_at"].present?
  end

  def test_refresh_with_invalid_refresh_token
    post "/api/v1/auth/refresh", headers: { "Authorization" => "Bearer #{SecureRandom.hex(32)}" }

    assert_response :unauthorized

    json = JSON.parse(response.body)
    assert json["error"].present?
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
