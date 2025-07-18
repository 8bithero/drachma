class TokenRefreshService < BaseService
  def initialize(params:)
    @refresh_token = params[:refresh_token]
  end

  def call
    validate_inputs
      .bind { |_| find_user }
      .bind { |user| generate_tokens(user) }
      .bind { |data| update_user_tokens(data) }
      .fmap { |data| format_response(data) }
  end

  private

  attr_reader :refresh_token

  def validate_inputs
    errors = []
    errors << "Refresh token is required" if refresh_token.blank?

    errors.empty? ? Success() : Failure(errors)
  end

  def find_user
    user = User.find_by(refresh_token: refresh_token)

    return Failure("Invalid token") unless user
    return Failure("Token has expired") if user.refresh_token_expires_at&.past?

    Success(user)
  end

  def generate_tokens(user)
    result = TokenGeneratorService.call(params: { user_id: user.id })
    return result if result.failure?

    token_data = result.value!
    Success(token_data.merge(user: user))
  end

  def update_user_tokens(data)
    result = UserUpdateService.call(params: {
      user: data[:user],
      refresh_token: data[:refresh_token],
      refresh_token_expires_at: data[:refresh_expiry]
    })

    return result if result.failure?

    updated_user = result.value![:user]
    Success(data.merge(user: updated_user))
  end

  def format_response(data)
    {
      access_token: data[:access_token],
      refresh_token: data[:refresh_token],
      refresh_token_expires_at: data[:refresh_expiry]
    }
  end
end
