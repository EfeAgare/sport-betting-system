class Bet < ApplicationRecord
  belongs_to :user
  belongs_to :game

  validates :amount, numericality: { greater_than: 0, less_than_or_equal_to: ->(bet) { bet.user&.balance || 0 }, message: "exceeds your available balance" }
  validates :bet_type, :pick, :amount, presence: true

  before_validation :set_default_values
  after_commit :update_game_odds

  private

  def set_default_values
    self.odds ||= 1 + rand * 4 # Random odds if not pre-set
  end

  def update_game_odds
    UpdateOddsJob.perform_later(self.game_id)
  end
end
