class UserUpdateService < BaseService
  ALLOWED_ATTRS = %i[first_name last_name email].freeze
  ALLOWED_NULLABLE_ATTRS = %i[refresh_token refresh_token_expires_at].freeze

  def initialize(params:)
    @user = params[:user]
    @update_params = params.except(:user)
  end

  def call
    validate_inputs
      .bind { |_| update_user }
      .fmap { |user| format_response(user) }
  end

  private

  attr_reader :user, :update_params

  def validate_inputs
    errors = []
    errors << "User is required" if user.blank?
    errors.empty? ? Success() : Failure(errors)
  end

  def update_user
    return Success(user) if user.update(attrs_to_update)
    Failure(user.errors.full_messages)
  end

  def attrs_to_update
    @attrs_to_update ||= regular_attributes.merge(nullable_attributes)
  end

  def regular_attributes
    update_params.slice(*ALLOWED_ATTRS).compact_blank
  end

  def nullable_attributes
    update_params.slice(*ALLOWED_NULLABLE_ATTRS)
  end

  def format_response(user)
    {
      user: user,
      updated_attributes: user.previous_changes.keys.map(&:to_sym)
    }
  end
end
