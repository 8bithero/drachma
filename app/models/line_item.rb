class LineItem < ApplicationRecord
  belongs_to :statement, counter_cache: true

  enum :item_type, {
    income: "income",
    expenditure: "expenditure"
  }

  validates :item_type, presence: true
  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :category, length: { maximum: 255 }, allow_blank: true
  validates :description, length: { maximum: 500 }, allow_blank: true

  delegate :user, to: :statement

  after_save :update_statement_calculations
  after_destroy :update_statement_calculations

  private

  def update_statement_calculations
    statement.update_calculated_fields!
  end
end
