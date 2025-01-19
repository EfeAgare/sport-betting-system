class UpdateLeaderboardJob < ApplicationJob
  queue_as :default

  def perform(user_id, bet_amount, status, created_at)
    # Calling the LeaderboardService to update the leaderboard
    LeaderboardService.update_leaderboard(user_id, bet_amount, status, created_at)
  end
end
