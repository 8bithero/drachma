require "test_helper"

class StatementUpsertServiceTest < ActiveSupport::TestCase
  def setup
    travel_to Time.zone.local(1990, 5, 13)
    @user = users(:homer)
  end

  def teardown
    travel_back
  end

  def test_fails_when_user_is_nil
    result = StatementUpsertService.call(params: { user: nil, slug: "1990-04" })
    assert result.failure?
    assert_includes result.failure, "User is required"
  end

  def test_fails_when_slug_is_blank
    result = StatementUpsertService.call(params: { user: @user, slug: nil })
    assert result.failure?
    assert_includes result.failure, "Month is required"
  end

  def test_fails_when_slug_format_invalid
    result = StatementUpsertService.call(params: { user: @user, slug: "May-1990" })
    assert result.failure?
    assert_includes result.failure, "Month must be in YYYY-MM format"
  end

  def test_fails_when_slug_month_in_future
    result = StatementUpsertService.call(params: { user: @user, slug: "1990-06" })
    assert result.failure?
    assert_includes result.failure, "Month cannot be in the future"
  end

  def test_creates_statement_when_none_exists
    result = StatementUpsertService.call(params: { user: @user, slug: "1990-04" })

    assert result.success?
    statement = result.value!
    assert_equal @user, statement.user
    assert_equal "1990-04", statement.slug
    assert_equal "April 1990", statement.name
  end

  def test_finds_existing_statement
    existing_statement = @user.statements.create!(slug: "1990-04", name: "Existing")

    result = StatementUpsertService.call(params: { user: @user, slug: "1990-04" })

    assert result.success?
    statement = result.value!
    assert_equal existing_statement.id, statement.id
    assert_equal "Existing", statement.name
  end

  def test_allows_slug_current_month
    result = StatementUpsertService.call(params: { user: @user, slug: "1990-05" })
    assert result.success?
  end
end
