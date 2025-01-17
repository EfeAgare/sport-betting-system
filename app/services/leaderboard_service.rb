class LeaderboardService
  def self.calculate
    leaderboard_cache_key = "leaderboard_data"

    # Cache for 30 minutes to avoid recalculating on every request
    Rails.cache.fetch(leaderboard_cache_key, expires_in: 30.minutes) do
      User.joins(:bets)
          .select("users.id, users.username, SUM(bets.amount) AS total_bets")
          .group("users.id")
          .order("total_bets DESC")
          .limit(20) # Top 20 users by total bet amount
    end
  end
end
