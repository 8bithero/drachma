class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_user, only: [ :create ]

  # TODO: This should use it's own service, not the UserLoginService
  def create
    user = User.new(user_params)
    if user.save
      result = UserLoginService.call(params: {
        email: user_params[:email],
        password: user_params[:password]
      })

      return render_error(result.failure) unless result.success?
      render json: AuthResponseSerializer.new(result.value!)
    else
      render_error(user.errors.full_messages, status: :unprocessable_entity)
    end
  end

  def show
    render json: UserSerializer.new(current_user)
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end
