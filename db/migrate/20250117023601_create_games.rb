class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.string :game_id, null: false
      t.string :home_team
      t.string :away_team
      t.integer :home_score, default: 0
      t.integer :away_score, default: 0
      t.integer :time_elapsed, default: 0
      t.string :status, default: "scheduled", null: false

      t.timestamps
    end

    add_index :games, :game_id, unique: true
  end
end
