class UserLoginService < BaseService
  def initialize(params:)
    @email = params[:email]
    @password = params[:password]
  end

  def call
    validate_inputs
      .bind { |_| authenticate_user }
      .bind { |user| generate_tokens(user) }
      .bind { |data| update_user_tokens(data) }
      .fmap { |data| format_response(data) }
  end

  private

  attr_reader :email, :password

  def validate_inputs
    errors = []
    errors << "Email is required" if email.blank?
    errors << "Password is required" if password.blank?

    errors.empty? ? Success() : Failure(errors)
  end

  def authenticate_user
    user = User.find_by(email: email)

    return Failure("User not found") unless user
    return Failure("Invalid password") unless user.authenticate(password)

    Success(user)
  end

  def generate_tokens(user)
    result = TokenGeneratorService.call(params: { user_id: user.id })
    return result if result.failure?

    token_date = result.value!
    Success(token_date.merge(user: user))
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
      refresh_token_expires_at: data[:refresh_expiry],
      user: format_user_response(data[:user])
    }
  end

  def format_user_response(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end
