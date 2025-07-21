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
    TokenGeneratorService.call(params: { user_id: user.id })
      .fmap { |token_data| token_data.merge(user: user) }
  end

  def update_user_tokens(data)
    UserUpdateService.call(params: {
      user: data[:user],
      refresh_token: data[:refresh_token],
      refresh_token_expires_at: data[:refresh_token_expires_at]
    }).fmap { |_| data }
  end
end
