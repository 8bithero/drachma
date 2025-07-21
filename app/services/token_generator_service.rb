class TokenGeneratorService < BaseService
  def initialize(params:)
    @user_id = params[:user_id]
  end

  def call
    validate_inputs
      .bind { |_| generate_tokens }
  end

  private

  attr_reader :user_id

  def validate_inputs
    errors = []
    errors << "UserId is required" if user_id.blank?

    errors.empty? ? Success() : Failure(errors)
  end

  def generate_tokens
    access_token = JsonWebToken.encode(user_id: user_id)
    refresh_token = SecureRandom.hex(32)
    refresh_token_expires_at = 30.days.from_now

    Success(
      user_id: user_id,
      access_token: access_token,
      refresh_token: refresh_token,
      refresh_token_expires_at: refresh_token_expires_at
    )
  end
end
