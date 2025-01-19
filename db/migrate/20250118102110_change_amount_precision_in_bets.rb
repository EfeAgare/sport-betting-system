class ChangeAmountPrecisionInBets < ActiveRecord::Migration[8.0]
  def up
    change_column :bets, :amount, :decimal, default: 0.0, precision: 15, scale: 2
  end

  def down
    change_column :bets, :amount, :decimal
  end
end
