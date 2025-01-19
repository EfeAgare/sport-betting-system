class AddIndexToJwtBlacklist < ActiveRecord::Migration[8.0]
  def up
    add_index :jwt_blacklists, :jti, unique: true
  end

  def down
    remove_index :jwt_blacklists, :jti
  end
end
