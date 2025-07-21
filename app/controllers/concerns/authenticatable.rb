module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user
  end

  private

  def authenticate_user
    token = header_token
    return render_error("Missing token") unless token.present?

    begin
      decoded_token = JsonWebToken.decode(token)
      @current_user = User.find(decoded_token[:user_id])

    rescue JWT::ExpiredSignature
      render_error("Expired token")
    rescue JWT::DecodeError
      render_error("Invalid token")
    end
  end

  def render_error(message, status: :unauthorized)
    render json: { error: message }, status: status
  end

  def current_user
    @current_user
  end

  def header_token
    request.headers["Authorization"]&.split(" ")&.last
  end
end
