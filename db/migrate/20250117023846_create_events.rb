class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.references :game, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :team, null: false
      t.string :player, null: false
      t.integer :minute, null: false

      t.timestamps
    end
  end
end
