class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false

      t.string :username, null: false
      t.decimal :balance, default: 0.0, precision: 15, scale: 2

      t.timestamps
    end

    ## Indexes
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
  end
end
