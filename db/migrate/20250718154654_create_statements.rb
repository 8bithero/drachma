class CreateStatements < ActiveRecord::Migration[8.0]
  def change
    create_table :statements do |t|
      t.references :user, null: false, foreign_key: true
      t.string :slug, null: false
      t.string :name, null: false
      t.integer :line_items_count, null: false, default: 0

      t.timestamps
    end
    add_index :statements, [ :user_id, :slug ], unique: true
  end
end
