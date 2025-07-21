class Statement < ApplicationRecord
  belongs_to :user
  has_many :line_items, dependent: :destroy

  validates :slug,
            presence: true,
            uniqueness: { scope: :user_id },
            format: { with: /\A\d{4}-\d{2}\z/, message: "must be in YYYY-MM format" }
  validates :name, presence: true

  def disposable_income_cents
    total_income_cents - total_expenditure_cents
  end

  def update_calculated_fields!
    self.total_income_cents = line_items.income.sum(:amount_cents)
    self.total_expenditure_cents = line_items.expenditure.sum(:amount_cents)
    self.ie_rating = calculate_ie_rating
    save!
  end

  private

  def calculate_ie_rating
    return "N/A" if total_income_cents.zero?

    ratio = total_expenditure_cents.to_f / total_income_cents.to_f

    case ratio
    when 0...0.1 then "A"
    when 0.1...0.3 then "B"
    when 0.3...0.5 then "C"
    else "D"
    end
  end
end
