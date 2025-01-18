class Api::V1::GamesController < ApplicationController
  include Validatable
  allow_unauthenticated_access

  # Creates a new game and clears any relevant cache
  def create
    GameValidator.new(game_params).validate!
    game = Game.new(game_params)
    # This raises ActiveRecord::RecordInvalid automatically if validation fails
    game.save!
    GameService.clear_all_game_cache
    render json: game, status: :created
  end

  # Retrieves a list of games with optional date filtering and pagination
  def index
    validate_pagination!
    validate_date_range!

    start_date = safe_parse_date(params[:start_date])
    end_date = safe_parse_date(params[:end_date])

    games = GameService.all(
      page: params[:page] || 1,
      per_page: params[:per_page] || 25,
      start_date: start_date,
      end_date: end_date
    )

    render json: games, meta: pagination_meta(games), status: :ok
  end

  # Retrieves a single game along with its events and calculated odds
  def show
    game = Game.includes(:events).find(params[:id])
    odds = game.calculate_odds

    render json: { game: game, odds: odds }, status: :ok
  end

  private

  # Strong parameters for game creation and updating
  def game_params
    params.require(:game).permit(:home_team, :away_team, :home_score, :away_score, :time_elapsed, :status, events_attributes: [ :event_type, :team, :player, :minute ])
  end
end
