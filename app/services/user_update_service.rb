class UserUpdateService < BaseService
  ALLOWED_ATTRS = %i[first_name last_name email refresh_token refresh_token_expires_at].freeze

  def initialize(params:)
    @user = params[:user]
    @update_params = params.except(:user)
  end

  def call
    validation_errors = validate_inputs
    return validation_errors unless validation_errors.success?

    if user.update(attributes_to_update)
      Success(
        user: user,
        updated_attributes: user.previous_changes.keys.map(&:to_sym)
      )
    else
      Failure(user.errors.full_messages)
    end
  end

  private

  attr_reader :user, :update_params

  def validate_inputs
    errors = []
    errors << "User is required" if user.blank?
    errors.empty? ? Success() : Failure(errors)
  end

  def attributes_to_update
    @attributes_to_update ||= update_params.slice(*  ALLOWED_ATTRS)
                                            .compact_blank
  end
end
