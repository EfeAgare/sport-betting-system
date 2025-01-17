class MockGameDataService
  # Start simulating continuous updates
  def start_continuous_updates
    loop do
      # Randomly pick a game ID to simulate an update for
      game_id = Game.pluck(:id).sample

      # Simulate a live game update
      game_update = generate_live_update(game_id)
      if game_update
        puts "Live Game Update: #{game_update}"
      end

      # Simulate a random bet placement
      user_id = User.pluck(:id).sample
      game_id_for_bet = Game.pluck(:id).sample
      bet_type = [ "winner", "scoreExact" ].sample
      pick = [ "home", "away", "2-1", "1-0" ].sample
      amount = rand(10..100)

      bet = simulate_bet_placement(user_id, game_id_for_bet, bet_type, pick, amount)
      if bet
        puts "New Bet Placed: #{bet}"
      end

      # Sleep for a random time between 2-5 seconds before continuing the loop
      sleep(rand(2..5))
    end
  end

  # Simulate a live game update
  def generate_live_update(game_id)
    game = Game.find_by(id: game_id)
    return nil unless game

    event_types = [ "goal", "yellowCard", "redCard", "substitution" ]
    event_type = event_types.sample
    team = [ "home", "away" ].sample

    update = {
      game_id: game.id,
      home_score: game.home_score,
      away_score: game.away_score,
      time_elapsed: game.time_elapsed + rand(5).to_i,
      event_type: event_type,
      team: team
    }

    if event_type == "goal"
      scorer = "Player #{rand(1..11)}"
      if team == "home"
        game.update(home_score: game.home_score + 1)
      else
        game.update(away_score: game.away_score + 1)
      end
      update[:scorer] = scorer
      update[:new_score] = "#{game.home_score}-#{game.away_score}"
    end

    # Publish the game update to the Redis channel
    publish_game_update(update)

    update
  end

  # Simulate bet placement
  def simulate_bet_placement(user_id, game_id, bet_type, pick, amount)
    user = User.find_by(id: user_id)
    return nil unless user && user.balance >= amount

    game = Game.find_by(id: game_id)
    return nil unless game

    bet_id = "B#{Bet.count + 1}"
    odds = (1 + rand * 4).round(2) # Generate random odds between 1.00 and 5.00

    new_bet = Bet.create!(
      user_id: user.id,
      game_id: game.id,
      bet_type: bet_type,
      pick: pick,
      amount: amount,
      odds: odds
    )

    # Deduct the amount from the user's balance
    user.update(balance: user.balance - amount)

    # Publish the game update and leaderboard updates to Redis
    publish_game_update(new_bet)
    publish_leaderboard_update(user)

    new_bet
  end

  # Publish game updates to the 'game_updates' Redis channel
  def publish_game_update(event)
    # Use Redis to publish the event to the game updates channel
    $redis.publish("game_updates", event.to_json)
  end

  # Publish leaderboard updates to the 'leaderboard_updates' Redis channel
  def publish_leaderboard_update(user)
    # Fetch top users sorted by balance
    leaderboard = User.order(balance: :desc).limit(10).pluck(:id, :username, :balance)
    # Publish leaderboard updates to the Redis channel
    $redis.publish("leaderboard_updates", leaderboard.to_json)
  end
end
