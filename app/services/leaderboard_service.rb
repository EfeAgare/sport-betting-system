class LeaderboardService
  LEADERBOARD_KEY = "leaderboard"
  WINS_KEY = "leaderboard_wins"
  LOSSES_KEY = "leaderboard_losses"

  def self.update_leaderboard(user_id, bet_amount, status, created_at)
    # Ensure bet_amount is converted to a float
    bet_amount = bet_amount.to_f

    # Update total bets in Redis sorted set
    current_total_bets = $redis.zscore(LEADERBOARD_KEY, user_id).to_f || 0
    new_total_bets = current_total_bets + bet_amount

    # Safely add the new total bets to the leaderboard
    $redis.zadd(LEADERBOARD_KEY, new_total_bets, user_id)

    # Update wins or losses based on the bet status
    if status == "win"
      $redis.zincrby(WINS_KEY, 1, user_id)
    elsif status == "loss"
      $redis.zincrby(LOSSES_KEY, 1, user_id)
    end

    # Store the bet creation time for date filtering, using timestamps
    $redis.hset("user_bets:#{user_id}", created_at.to_i, new_total_bets.to_s)
  end

  def self.calculate(start_date: nil, end_date: nil, page: 1, per_page: 25)
    leaderboard_cache_key = "leaderboard_data"

    # Cache for 30 minutes to avoid recalculating on every request
    Rails.cache.fetch(leaderboard_cache_key, expires_in: 30.minutes) do
      # Fetch user IDs from Redis sorted set
      user_ids = $redis.zrevrange(LEADERBOARD_KEY, (page - 1) * per_page, page * per_page - 1)

      leaderboard_data = user_ids.map do |user_id|
        total_bets = $redis.zscore(LEADERBOARD_KEY, user_id).to_f
        wins = $redis.zscore(WINS_KEY, user_id).to_i
        losses = $redis.zscore(LOSSES_KEY, user_id).to_i

        # Filter by date if start_date and end_date are provided
        bet_dates = $redis.hkeys("user_bets:#{user_id}").map(&:to_i)
        filtered_bets = bet_dates.select { |date| (start_date.nil? || date >= start_date.to_i) && (end_date.nil? || date <= end_date.to_i) }

        {
          id: user_id,
          username: User.find_by(id: user_id)&.username,
          total_bets: total_bets,
          wins: wins,
          losses: losses,
          bets_in_date_range: filtered_bets.size
        }
      end

      leaderboard_data
    end
  end
end
