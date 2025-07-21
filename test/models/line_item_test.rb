require "test_helper"

class LineItemTest < ActiveSupport::TestCase
  def setup
    @statement = statements(:homer_july)
    @user = users(:homer)
  end

  def test_belongs_to_statement
    line_item = LineItem.new(statement: @statement)
    assert_equal @statement, line_item.statement
  end

  def test_enum_values
    assert_includes LineItem.item_types.keys, "income"
    assert_includes LineItem.item_types.keys, "expenditure"
  end

  def test_valid_with_valid_attributes
    line_item = LineItem.new(
      statement: @statement,
      item_type: "income",
      amount_cents: 1000,
      category: "Salary",
      description: "Monthly salary"
    )
    assert line_item.valid?
  end

  def test_invalid_without_item_type
    line_item = LineItem.new(
      statement: @statement,
      amount_cents: 1000
    )
    line_item.item_type = nil
    refute line_item.valid?
    assert_includes line_item.errors[:item_type], "can't be blank"
  end

  def test_invalid_with_amount_cents_zero
    line_item = LineItem.new(
      statement: @statement,
      item_type: "income",
      amount_cents: 0
    )
    refute line_item.valid?
    assert_includes line_item.errors[:amount_cents], "must be greater than 0"
  end

  def test_category_maximum_length
    line_item = LineItem.new(
      statement: @statement,
      item_type: "income",
      amount_cents: 1000,
      category: "a" * 256
    )
    refute line_item.valid?
    assert_includes line_item.errors[:category], "is too long (maximum is 255 characters)"
  end

  def test_description_maximum_length
    line_item = LineItem.new(
      statement: @statement,
      item_type: "income",
      amount_cents: 1000,
      description: "a" * 501
    )
    refute line_item.valid?
    assert_includes line_item.errors[:description], "is too long (maximum is 500 characters)"
  end

  def test_user_delegation
    @statement.update(user: @user)
    line_item = LineItem.new(statement: @statement)
    assert_equal @user, line_item.user
  end

  def test_statement_recalculation_on_save
    previous_total = @statement.total_income_cents
    LineItem.create!(
      statement: @statement,
      item_type: "income",
      amount_cents: 1234
    )

    @statement.reload
    refute_equal previous_total, @statement.total_income_cents
  end
end
