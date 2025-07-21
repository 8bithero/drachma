class AddCalculatedFieldsToStatements < ActiveRecord::Migration[8.0]
  def change
    add_column :statements, :total_income_cents, :integer, default: 0
    add_column :statements, :total_expenditure_cents, :integer, default: 0
    add_column :statements, :ie_rating, :string

    add_index :statements, :ie_rating
  end
end
