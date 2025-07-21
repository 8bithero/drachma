require "test_helper"

class Api::V1::Statements::LineItemsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:homer)
    @token = JsonWebToken.encode(user_id: @user.id)
    @statement = statements(:homer_july)
    @line_item = line_items(:homer_salary)
  end

  # --------------------------------------------
  # POST /statements/:slug/line_items
  # --------------------------------------------
  def test_create_line_items_success
    params = {
      line_items: [{
        item_type: "income",
        category: "Bonus",
        amount_cents: 50_000,
        description: "Year-end bonus"
      }]
    }

    assert_difference -> { LineItem.count }, 1 do
      post "/api/v1/statements/2025-07/line_items",
           headers: auth_header,
           params: params

      assert_response :created
      assert json_response["line_items"].present?
    end
  end

  # --------------------------------------------
  # GET /statements/:slug/line_items
  # --------------------------------------------
  def test_index_returns_line_items
    get "/api/v1/statements/2025-07/line_items", headers: auth_header

    assert_response :success
    json = json_response

    assert_equal 2, json["line_items"].size

    categories = json["line_items"].map { |item| item["category"] }
    assert_includes categories, "Salary"
    assert_includes categories, "Beer"
  end

  def test_index_handles_missing_statement
    get "/api/v1/statements/2099-01/line_items", headers: auth_header

    assert_response :not_found
    assert_match(/not found/, json_response["error"])
  end

  private

  def auth_header
    { "Authorization" => "Bearer #{@token}" }
  end

  def json_response
    JSON.parse(response.body)
  end
end
