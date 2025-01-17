class LeaderboardService
  def self.calculate
    leaderboard_cache_key = "leaderboard_data"

    Rails.cache.fetch(leaderboard_cache_key) do
      User.joins(:bets)
        .select("users.id, users.username, SUM(bets.amount) AS total_bets")
        .group("users.id")
        .order("total_bets DESC")
    end
  end
end
