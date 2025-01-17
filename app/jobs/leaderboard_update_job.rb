class LeaderboardUpdateJob < ApplicationJob
  queue_as :default

  def perform
    leaderboard = LeaderboardService.calculate

    leaderboard_data = leaderboard.as_json(only: [ :id, :username, :total_bets ])

    # Publish the updated leaderboard data to Redis for real-time updates
    $redis.publish("leaderboard_updates", leaderboard_data.to_json)
  end
end
