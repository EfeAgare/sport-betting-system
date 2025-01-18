class Api::V1::BetsController < ApplicationController
  include Validatable
  # Limit bet creation attempts to 5 within 1 minute
  rate_limit to: 5, within: 1.minute, only: :create, with: -> { render json: { error: "Too many bet attempts. Please try again later." }, status: :too_many_requests }

  # Retrieves all bets for the current user,
  # ordered by creation time (newest first).
  def index
    validate_pagination!
    validate_date_range!

    @bets = current_user.bets.order(created_at: :desc)

    # Apply date filtering only if valid start_date and end_date are present
    if params[:start_date].present? || params[:end_date].present?
      start_date = safe_parse_date(params[:start_date])
      end_date = safe_parse_date(params[:end_date])

      # Filter based on the parsed dates
      @bets = @bets.where(created_at: start_date..end_date) if start_date && end_date
    end

    # Apply pagination
    @bets = @bets.page(params[:page]).per(params[:per_page] || 25)

    render json: @bets, meta: pagination_meta(@bets), status: :ok
  end

  # Creates a new bet for the current user.
  def create
    BetValidator.new(bet_params).validate!

    # Ensure the user has sufficient balance to place the bet.
    ensure_sufficient_balance!(current_user, bet_params[:amount].to_f)

    @bet = current_user.bets.new(bet_params)

    Bet.transaction do
      # Save the new bet record.
      @bet.save!

      # Deduct the bet amount from the user's balance.
      current_user.update!(balance: current_user.balance - @bet.amount)

      render json: @bet, status: :created
    end
  end

  # Retrieves the betting history for a specific user.
  def history
    validate_pagination!
    validate_date_range!

    user = User.find(params[:user_id])

    @bets = user.bets.order(created_at: :desc)

    if params[:start_date].present? || params[:end_date].present?
      start_date = safe_parse_date(params[:start_date])
      end_date = safe_parse_date(params[:end_date])

      # Filter based on the parsed dates
      @bets = @bets.where(created_at: start_date..end_date) if start_date && end_date
    end

    @bets = @bets.page(params[:page]).per(params[:per_page] || 25)

    render json: @bets, meta: pagination_meta(@bets), status: :ok
  end

  private

  # Strong parameters for creating a bet.
  def bet_params
    params.require(:bet).permit(:game_id, :bet_type, :pick, :amount, :odds)
  end

  # Ensure the user has enough balance to place the bet.
  def ensure_sufficient_balance!(user, amount)
    if user.balance < amount
      raise InsufficientBalanceError, "Your balance is insufficient to place this bet."
    end
  end
end
