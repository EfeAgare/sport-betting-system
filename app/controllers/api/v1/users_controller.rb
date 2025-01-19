class Api::V1::UsersController < ApplicationController
  allow_unauthenticated_access only: [ :index ]

  rate_limit to: 3, within: 1.minute, only: :update, with: -> {
    response.headers["Retry-After"] = 240.to_s
    render json: { error: "Too many signup attempts. Please try again later." }, status: :too_many_requests
  }

  def index
    validate_pagination!
    validate_date_range!
    @users = User.order(created_at: :desc)

    # Apply date filtering only if valid start_date and end_date are present
    if params[:start_date].present? || params[:end_date].present?
      start_date = safe_parse_date(params[:start_date])
      end_date = safe_parse_date(params[:end_date])

      # Filter based on the parsed dates
      @users = @users.where(created_at: start_date..end_date) if start_date && end_date
    end

    @users = @users.page(params[:page]).per(params[:per_page] || 25)

    render json: {
      users: @users,
      meta: pagination_meta(@users)
    }, status: :ok
  end

  def update
    UserValidator.new(user_params, required_fields: [ :balance, :username ]).validate!
    current_user.update!(user_params)
    render json: current_user, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:balance, :username)
  end
end
