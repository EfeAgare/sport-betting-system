class Game < ApplicationRecord
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
    total_bets = bets.sum(:amount)
    return { home: 0, away: 0, draw: 0 } if total_bets.zero?

    home_bets = bets.where(pick: "home").sum(:amount)
    away_bets = bets.where(pick: "away").sum(:amount)
    draw_bets = bets.where(pick: "draw").sum(:amount)

    # Calculate odds based on the total bets and individual bets
    home_odds = total_bets / (home_bets.nonzero? || 1)
    away_odds = total_bets / (away_bets.nonzero? || 1)
    draw_odds = total_bets / (draw_bets.nonzero? || 1)

    { home: home_odds.round(2), away: away_odds.round(2), draw: draw_odds.round(2) }
  end

  private

  def broadcast_game_update
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
    self.status ||= "scheduled"
  end

  def set_game_id
    last_game_id = Game.maximum(:id) || 0
    self.game_id ||= "G#{last_game_id + 1}"
  end
end
