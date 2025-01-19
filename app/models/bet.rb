class Bet < ApplicationRecord
  # Represents a bet placed by a user on a game.
  belongs_to :user
  belongs_to :game

  validates :amount, numericality: { greater_than: 0, less_than_or_equal_to: ->(bet) { bet.user&.balance || 0 }, message: "exceeds your available balance" }
  validates :bet_type, :pick, :amount, presence: true

  validates :status, inclusion: { in: %w[pending win loss], message: "%{value} must be type: pending win loss" }

  before_validation :set_default_values

  after_save_commit :update_and_send_leaderboard

  validate :odds_within_range

  private

  def set_default_values
    self.odds ||= 1 + rand * 4 # Random odds if not pre-set
    self.status ||= "pending"   # Set default status if not provided
  end

  def update_and_send_leaderboard
    # Update the leaderboard in Redis
    UpdateLeaderboardJob.perform_later(user.id, amount, status, created_at)

    # Trigger background job to calculate and send leaderboard
    LeaderboardUpdateJob.perform_later
  end

  def odds_within_range
    return if odds.nil?

    unless odds.between?(1.0, 5.0)
      errors.add(:odds, "must be between 1.0 and 5.0")
    end
  end
end
