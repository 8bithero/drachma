require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "test@example.com",
      first_name: "Test",
      last_name: "User",
      password: "password123",
      refresh_token: SecureRandom.hex(32),
      refresh_token_expires_at: 1.day.from_now
    )
  end

  def test_valid_user
    assert @user.valid?
  end

  def test_email_must_be_present_and_valid
    @user.email = ""
    refute @user.valid?
    assert_includes @user.errors[:email], "can't be blank"

    @user.email = "invalid_email"
    refute @user.valid?
    assert_includes @user.errors[:email], "is invalid"
  end

  def test_email_must_be_unique
    @user.save!

    duplicate_user = User.new(
      email: "test@example.com",
      first_name: "Another",
      last_name: "User",
      password: "password123"
    )

    refute duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  def test_first_and_last_name_presence_and_length
    @user.first_name = ""
    refute @user.valid?

    @user.first_name = "a" * 51
    refute @user.valid?

    @user.last_name = ""
    refute @user.valid?

    @user.last_name = "a" * 51
    refute @user.valid?
  end

  def test_password_minimum_length
    @user.password = "short"
    refute @user.valid?
    assert_includes @user.errors[:password], "is too short (minimum is 8 characters)"
  end

  def test_refresh_token_length_and_hex_format
    @user.refresh_token = "abc"
    refute @user.valid?
    assert_includes @user.errors[:refresh_token], "is the wrong length (should be 64 characters)"

    @user.refresh_token = "g" * 64
    refute @user.valid?
    assert_includes @user.errors[:refresh_token], "must be hexadecimal"
  end

  def test_refresh_token_expiry_presence_if_token_set
    @user.refresh_token_expires_at = nil
    refute @user.valid?
    assert_includes @user.errors[:refresh_token_expires_at], "can't be blank"
  end

  def test_refresh_token_expiry_must_be_in_future
    @user.refresh_token_expires_at = 1.day.ago
    refute @user.valid?
    assert_includes @user.errors[:refresh_token_expires_at], "must be in the future"
  end
end
