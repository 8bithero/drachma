class Api::V1::AuthController < Api::V1::ApplicationController
  skip_before_action :authenticate_user, only: [ :login, :refresh ]

  def login
    result = UserLoginService.call(params: login_params)

    if result.success?
      render json: result.value!
    else
      render json: { error: result.failure }, status: :unauthorized
    end
  end

  def logout
    @current_user.update(refresh_token: nil)
    render json: { message: "Logged out successfully" }, status: :ok
  end

  def refresh
    result = TokenRefreshService.call(params: { refresh_token: header_token })

    if result.success?
      render json: result.value!
    else
      render json: { error: result.failure }, status: :unauthorized
    end
  end

  private

  def login_params
    params.permit(:email, :password)
  end
end
