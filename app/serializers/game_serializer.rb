class GameSerializer < ActiveModel::Serializer
  attributes :id, :game_id, :home_team, :away_team, :home_score, :away_score, :time_elapsed, :status, :created_at, :updated_at
  attribute :betting_odds

  has_many :events

  def betting_odds
    object.calculate_odds
  end
end
