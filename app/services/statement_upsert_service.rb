class StatementUpsertService < BaseService
  def initialize(params:)
    @user = params[:user]
    @slug = params[:slug]
  end

  def call
    validate_inputs
      .bind { |_| find_or_create_statement }
  end

  private

  attr_reader :user, :slug

  def validate_inputs
    errors = []
    errors << "User is required" if user.blank?
    errors << "Month is required" if slug.blank?

    if slug.present?
      valid_format = valid_slug_format?(slug)
      errors << "Month must be in YYYY-MM format" unless valid_format
      errors << "Month cannot be in the future" if valid_format && future_month?(slug)
    end

    errors.empty? ? Success() : Failure(errors)
  end

  def valid_slug_format?(slug)
    Date.strptime(slug, "%Y-%m")
    true
  rescue Date::Error
    false
  end

  def future_month?(slug)
    date = Date.strptime(slug, "%Y-%m")
    date > Date.current.beginning_of_month
  end

  def find_or_create_statement
    statement = user.statements.find_or_initialize_by(slug: slug)

    if statement.new_record?
      statement.name = default_name_from_slug(slug)
      return Failure(statement.errors.full_messages) unless statement.save
    end

    Success(statement)
  end

  def default_name_from_slug(slug)
    Date.strptime(slug, "%Y-%m").strftime("%B %Y")
  end
end
