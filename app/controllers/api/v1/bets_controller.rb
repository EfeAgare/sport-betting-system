class Api::V1::BetsController < ApplicationController
  def index
    @bets = current_user.bets.order(created_at: :desc)
    render json: @bets
  end

  def create
    @bet = current_user.bets.new(bet_params)
    if @bet.save
      # Clear the leaderboard cache
      Rails.cache.delete("leaderboard_data")
      render json: @bet, status: :created
    else
      render json: @bet.errors.full_messages, status: :unprocessable_entity
    end
  end

  def history
    user = User.find(params[:user_id])
    bets = user.bets.order(created_at: :desc)
    render json: bets, status: :ok
  end

  private

  def bet_params
    params.require(:bet).permit(:game_id, :bet_type, :pick, :amount, :odds)
  end
end
