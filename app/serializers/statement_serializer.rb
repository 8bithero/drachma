class StatementSerializer
  def initialize(statement, options = {})
    @statement = statement
    @include_line_items = options[:include_line_items] || false
  end

  def as_json
    base_attributes.tap do |json|
      json[:line_items] = serialize_line_items if @include_line_items
    end
  end

  def self.serialize_collection(statements, options = {})
    statements.map { |statement| new(statement, options).as_json }
  end

  private

  attr_reader :statement

  def base_attributes
    {
      id: statement.id,
      slug: statement.slug,
      name: statement.name,
      total_income_cents: statement.total_income_cents,
      total_expenditure_cents: statement.total_expenditure_cents,
      disposable_income_cents: statement.disposable_income_cents,
      ie_rating: statement.ie_rating,
      line_items_count: statement.line_items_count,
      created_at: statement.created_at,
      updated_at: statement.updated_at
    }
  end

  def serialize_line_items
    statement.line_items.map { |item| LineItemSerializer.new(item).as_json }
  end
end
