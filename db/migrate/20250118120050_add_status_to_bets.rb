class AddStatusToBets < ActiveRecord::Migration[8.0]
  def change
    add_column :bets, :status, :string, default: 'pending' # Set a default status if needed
    add_index :bets, :status
  end
end
