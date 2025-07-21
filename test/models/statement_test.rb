require "test_helper"

class StatementTest < ActiveSupport::TestCase
  def setup
    @user = users(:homer)
    @statement = Statement.create!(
      user: @user,
      slug: "1990-05",
      name: "Test Statement"
    )
  end

  def test_valid_with_valid_attributes
    assert @statement.valid?
  end

  def test_invalid_without_slug
    @statement.slug = nil
    refute @statement.valid?
    assert_includes @statement.errors[:slug], "can't be blank"
  end

  def test_invalid_slug_format
    @statement.slug = "May-1990"
    refute @statement.valid?
    assert_includes @statement.errors[:slug], "must be in YYYY-MM format"
  end

  def test_invalid_without_name
    @statement.name = nil
    refute @statement.valid?
    assert_includes @statement.errors[:name], "can't be blank"
  end

  def test_disposable_income_cents_calculates_correctly
    @statement.total_income_cents = 5000
    @statement.total_expenditure_cents = 2000
    assert_equal 3000, @statement.disposable_income_cents
  end

  def test_update_calculated_fields_updates_totals
    @statement.line_items.create!(item_type: "income", amount_cents: 1000)
    @statement.line_items.create!(item_type: "expenditure", amount_cents: 250)

    @statement.update_calculated_fields!

    assert_equal 1000, @statement.total_income_cents
    assert_equal 250, @statement.total_expenditure_cents
  end

  def test_update_calculated_fields_sets_ie_rating
    @statement.line_items.create!(item_type: "income", amount_cents: 1000)
    @statement.line_items.create!(item_type: "expenditure", amount_cents: 200)

    @statement.update_calculated_fields!

    assert_equal "B", @statement.ie_rating
  end

  def test_calculate_ie_rating_returns_na_when_income_zero
    @statement.total_income_cents = 0
    @statement.total_expenditure_cents = 100
    @statement.send(:update_calculated_fields!)

    assert_equal "N/A", @statement.ie_rating
  end
end
