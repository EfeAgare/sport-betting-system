class Api::V1::GamesController < ApplicationController
  allow_unauthenticated_access

  def create
    game = Game.new(game_params)
    if game.save
      GameService.clear_all_game_cache
      render json: game, status: :created
    else
      render json: { errors: game.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    games = GameService.all(
      page: params[:page] || 1,
      per_page: params[:per_page] || 25
    )

    render json: games, status: :ok
  end

  def show
    game = Game.includes(:events).find(params[:id])
    odds = game.calculate_odds

    render json: { game: game, odds: odds }, status: :ok
  end

  private

  def game_params
    params.require(:game).permit(:home_team, :away_team, :home_score, :away_score, :time_elapsed, :status, events_attributes: [ :event_type, :team, :player, :minute ])
  end
end
