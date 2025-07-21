class Api::V1::StatementsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:homer)
    @token = JsonWebToken.encode(user_id: @user.id)
  end

  def test_rejects_request_without_token
    get "/api/v1/statements"
    assert_response :unauthorized
    assert_includes json_response["error"], "Missing token"
  end

  def test_rejects_request_with_invalid_token
    get "/api/v1/statements", headers: { "Authorization" => "Bearer invalidtoken" }
    assert_response :unauthorized
  end

  def test_allows_request_with_valid_token
    get "/api/v1/statements", headers: { "Authorization" => "Bearer #{@token}" }
    assert_response :success
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
