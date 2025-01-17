class Api::V1::BetsController < ApplicationController
  def index
    @bets = current_user.bets.order(created_at: :desc)
    render json: @bets
  end

  def create
    @bet = current_user.bets.new(bet_params)

    Bet.transaction do
      if @bet.save
        current_user.update!(balance: current_user.balance - @bet.amount)
        # Ensure the leaderboard is always up-to-date after each bet.
        Rails.cache.delete("leaderboard_data")
        render json: @bet, status: :created
      else
        render json: @bet.errors.full_messages, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid
    render json: { error: "Unable to place bet. Please try again." }, status: :unprocessable_entity
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
