class CreateLineItems < ActiveRecord::Migration[8.0]
  def change
    create_table :line_items do |t|
      t.references :statement, null: false, foreign_key: true
      t.string :item_type, null: false
      t.string :category
      t.string :description
      t.integer :amount_cents, default: 0

      t.timestamps
    end
    add_index :line_items, :item_type
    add_index :line_items, [ :statement_id, :item_type ]
    add_index :line_items, :category
  end
end
