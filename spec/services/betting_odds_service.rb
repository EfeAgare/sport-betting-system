class BettingOddsService
  MIN_ODDS = 1.01
  MAX_ODDS = 5.0

  def initialize(game)
    @game = game
  end

  def calculate
    total_bets = @game.bets.sum(:amount)
    return default_odds if total_bets.zero?

    home_bets = @game.bets.where(pick: "home").sum(:amount)
    away_bets = @game.bets.where(pick: "away").sum(:amount)
    draw_bets = @game.bets.where(pick: "draw").sum(:amount)

    {
      home: calculate_and_validate_odds(total_bets, home_bets),
      away: calculate_and_validate_odds(total_bets, away_bets),
      draw: calculate_and_validate_odds(total_bets, draw_bets)
    }
  end

  private

  def calculate_and_validate_odds(total, category_bets)
    odds = total / (category_bets.nonzero? || 1)
    normalize_odds(odds).round(2)
  end

  def normalize_odds(odds)
    return MIN_ODDS if odds < MIN_ODDS
    return MAX_ODDS if odds > MAX_ODDS
    odds
  end

  def default_odds
    { home: MIN_ODDS, away: MIN_ODDS, draw: MIN_ODDS }
  end
end
