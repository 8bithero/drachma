class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_user, only: [ :login, :refresh ]

  def login
    result = UserLoginService.call(params: login_params)

    if result.success?
      render json: AuthResponseSerializer.new(result.value!)
    else
      render_error(result.failure)
    end
  end

  def logout
    result = UserUpdateService.call(params: {
      user: @current_user,
      refresh_token: nil,
      refresh_token_expires_at: nil
    })
    if result.success?
      render json: { message: "Logged out successfully" }, status: :ok
    else
      render_error(result.failure)
    end
  end

  def refresh
    result = TokenRefreshService.call(params: { refresh_token: header_token })

    if result.success?
      render json: TokenResponseSerializer.new(result.value!)
    else
      render_error(result.failure)
    end
  end

  private

  def login_params
    params.permit(:email, :password)
  end
end
