class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :refresh_token
      t.datetime :refresh_token_expires_at

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :refresh_token, unique: true
  end
end
