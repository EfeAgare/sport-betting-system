class LeaderboardUpdateJob < ApplicationJob
  queue_as :default

  def perform(bet)
    leaderboard = LeaderboardService.calculate

    leaderboard_data = leaderboard.as_json(only: [ :id, :username, :total_bets ])

    # Now, publish the JSON string to Redis
    $redis.publish("leaderboard_updates", leaderboard_data.to_json)
  end
end
