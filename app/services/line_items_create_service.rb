class LineItemsCreateService < BaseService
  def initialize(params:)
    @user = params[:user]
    @statement_slug = params[:slug]
    @line_items = params[:line_items]
  end

  def call
    validate_inputs
      .bind { |_| find_or_create_statement }
      .bind { |statement| build_line_items(statement) }
      .bind { |statement| save_statement(statement) }
  end

  private

  attr_reader :user, :statement_slug, :line_items

  def validate_inputs
    errors = []
    errors << "User is required" if user.blank?
    errors << "Month is required" if statement_slug.blank?
    errors << "Line items are required" if line_items.blank?

    errors.empty? ? Success() : Failure(errors)
  end

  def find_or_create_statement
    StatementUpsertService.call(params: { user: user, slug: statement_slug })
  end

  def build_line_items(statement)
    invalid_items = []

    line_items.each_with_index do |item_params, index|
      item = statement.line_items.build(item_params.slice(:item_type, :category, :amount_cents, :description))
      invalid_items << "Item #{index + 1}: #{item.errors.full_messages.join(', ')}" unless item.valid?
    end

    return Failure(invalid_items) if invalid_items.any?
    Success(statement)
  end

  def save_statement(statement)
    statement.save ? Success(statement) : Failure(statement.errors.full_messages)
  end
end
