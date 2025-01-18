class LeaderboardUpdateJob < ApplicationJob
  queue_as :default

  def perform(start_date: nil, end_date: nil)
    leaderboard = LeaderboardService.calculate(start_date: start_date, end_date: end_date)

    leaderboard_data = leaderboard.as_json(only: [ :id, :username, :total_bets, :wins, :losses ])

    # Publish the updated leaderboard data to Redis for real-time updates
    $redis.publish("leaderboard_updates", leaderboard_data.to_json)
  end
end
