class AddIndexesForBetAndGameQueries < ActiveRecord::Migration[8.0]
  def change
    add_index :bets, :created_at
    add_index :bets, :amount
    add_index :games, :created_at
  end
end
