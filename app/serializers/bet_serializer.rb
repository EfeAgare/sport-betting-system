class BetSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :game_id, :bet_type, :pick, :amount, :odds, :created_at, :updated_at
end
