class CreateBets < ActiveRecord::Migration[8.0]
  def change
    create_table :bets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.string :bet_type
      t.string :pick
      t.decimal :amount
      t.decimal :odds

      t.timestamps
    end
  end
end
