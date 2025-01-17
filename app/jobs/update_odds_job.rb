class UpdateOddsJob < ApplicationJob
  queue_as :default

  def perform(game_id)
    game = Game.find(game_id)
    new_odds = game.calculate_odds

    $redis.publish("odds_updates", { game_id: game.id, odds: new_odds }.to_json)
  end
end
