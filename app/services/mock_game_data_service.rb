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

    # Create the bet with a pending status initially
    new_bet = Bet.create!(
      user_id: user.id,
      game_id: game.id,
      bet_type: bet_type,
      pick: pick,
      amount: amount,
      odds: (1 + rand * 4).round(2), # Generate random odds between 1.00 and 5.00
      status: "pending" # Set initial status to pending
    )

    # Deduct the amount from the user's balance
    user.update(balance: user.balance - amount)

    # Determine the outcome of the bet (for simulation purposes)
    bet_outcome = determine_bet_outcome(new_bet) # This method should determine if the bet is a win or loss

    # Update the bet status based on the outcome
    new_bet.update(status: bet_outcome)

    # Update the leaderboard in Redis
    LeaderboardService.update_leaderboard(user.id, amount, bet_outcome, new_bet.created_at)

    # Publish the game update and leaderboard updates to Redis
    publish_game_update(new_bet)
    publish_leaderboard_update

    new_bet
  end

  def determine_bet_outcome(bet)
    # Simulate the outcome of the bet (this should be based on actual game results)
    # For example, if the bet is a win, return 'win', otherwise return 'loss'
    # This is a placeholder; implement your actual logic here
    rand < 0.5 ? "win" : "loss" # Randomly determine win/loss for simulation
  end

  # Publish game updates to the 'game_updates' Redis channel
  def publish_game_update(event)
    # Use Redis to publish the event to the game updates channel
    $redis.publish("game_updates", event.to_json)
  end

  # Publish leaderboard updates to the 'leaderboard_updates' Redis channel
  def publish_leaderboard_update(start_date: nil, end_date: nil, page: 1, per_page: 25)
    # Fetch the leaderboard data based on the provided parameters
    leaderboard = LeaderboardService.calculate(start_date: start_date, end_date: end_date, page: page, per_page: per_page)

    # Publish leaderboard updates to the Redis channel
    $redis.publish("leaderboard_updates", leaderboard.to_json)
  end
end
