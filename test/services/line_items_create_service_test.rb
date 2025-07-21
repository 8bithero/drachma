require "test_helper"

class LineItemsCreateServiceTest < ActiveSupport::TestCase
  def setup
    @user = users(:homer)
    @slug = "1989-12"
    @valid_line_items = [
      { item_type: "income", category: "Salary", amount_cents: 1000_00, description: "Monthly salary" },
      { item_type: "expenditure", category: "Beer", amount_cents: 200_00, description: "Duff beer" }
    ]
  end

  def test_success_with_valid_inputs
    result = call_service(@user, @slug, @valid_line_items)

    assert result.success?
    statement = result.value!
    assert_equal @slug, statement.slug
    assert_equal @user, statement.user
    assert_equal 2, statement.line_items.count
  end

  def test_failure_with_missing_user
    result = call_service(nil, @slug, @valid_line_items)

    assert result.failure?
    assert_includes result.failure, "User is required"
  end

  def test_failure_with_missing_slug
    result = call_service(@user, nil, @valid_line_items)

    assert result.failure?
    assert_includes result.failure, "Month is required"
  end

  def test_failure_with_missing_line_items
    result = call_service(@user, @slug, nil)

    assert result.failure?
    assert_includes result.failure, "Line items are required"
  end

  def test_failure_with_invalid_line_items
    invalid_items = [
      { item_type: "income", category: "Salary", description: "Missing amount" }
    ]

    result = call_service(@user, @slug, invalid_items)

    assert result.failure?
    assert result.failure.any? { |msg| msg.include?("Item 1") }
  end

  private

  def call_service(user, slug, line_items)
    LineItemsCreateService.call(params: {
      user: user,
      slug: slug,
      line_items: line_items
    })
  end
end
