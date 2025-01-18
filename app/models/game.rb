class Game < ApplicationRecord
  # Represents a game that users can place bets on.

  has_many :bets, dependent: :destroy
  has_many :events, dependent: :destroy

  after_update_commit :broadcast_game_update

  validates :game_id, presence: true, uniqueness: true
  validates :home_team, :away_team, presence: true
  validates :home_score, :away_score, :time_elapsed, presence: true

  validates :status, inclusion: { in: %w[scheduled ongoing paused finished cancelled postponed abandoned] }
  accepts_nested_attributes_for :events

  after_initialize :set_default_status, if: :new_record?
  after_initialize :set_game_id

  def calculate_odds
    # Calculate the betting odds for the game.
    BettingOddsService.new(self).calculate
  end

  private

  def broadcast_game_update
    # Publish game updates to the Redis channel.
    $redis.publish(
      "game_updates",
      {
        game_id: id,
        home_score: home_score,
        away_score: away_score,
        event: changes
      }.to_json
    )
  end

  def set_default_status
    # Set the default status of the game to "scheduled".
    self.status ||= "scheduled"
  end

  def set_game_id
    # Automatically generate a unique game ID.
    last_game_id = Game.maximum(:id) || 0
    self.game_id ||= "G#{last_game_id + 1}"
  end
end
