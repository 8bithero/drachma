class LineItemSerializer
  def initialize(line_item)
    @line_item = line_item
  end

  def as_json
    {
      id: line_item.id,
      item_type: line_item.item_type,
      category: line_item.category,
      amount_cents: line_item.amount_cents,
      description: line_item.description,
      created_at: line_item.created_at,
      updated_at: line_item.updated_at
    }
  end

  def self.serialize_collection(line_items)
    line_items.map { |item| new(item).as_json }
  end

  private

  attr_reader :line_item
end
