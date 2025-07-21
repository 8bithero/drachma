require "test_helper"

class Api::V1::LineItemsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:homer)
    @token = JsonWebToken.encode(user_id: @user.id)
    @line_item = line_items(:homer_salary)
  end

  # --------------------------------------------
  # GET /line_items
  # --------------------------------------------
  def test_index_returns_line_items
    get "/api/v1/line_items", headers: auth_header

    assert_response :success
    json = json_response

    assert_equal 2, json.size

    categories = json.pluck("category")
    assert_includes categories, "Salary"
    assert_includes categories, "Beer"
  end

  def test_index_handles_invalid_user
    @token = "h4ck3r"
    get "/api/v1/line_items", headers: auth_header

    assert_response :unauthorized
    assert_match(/Invalid token/, json_response["error"])
  end

  # --------------------------------------------
  # PUT /line_items/:id
  # --------------------------------------------
  def test_update_line_item
    payload = { amount_cents: 150_000 }

    put "/api/v1/line_items/#{@line_item.id}",
        headers: auth_header,
        params: payload

    assert_response :success
    assert_equal 150_000, json_response["amount_cents"]
  end

  # --------------------------------------------
  # DELETE /line_items/:id
  # --------------------------------------------
  def test_destroy_line_item
    assert_difference -> { LineItem.count }, -1 do
      delete "/api/v1/line_items/#{@line_item.id}", headers: auth_header
      assert_response :no_content
    end
  end

  private

  def auth_header
    { "Authorization" => "Bearer #{@token}" }
  end

  def json_response
    JSON.parse(response.body)
  end
end
