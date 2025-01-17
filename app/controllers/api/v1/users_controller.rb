class Api::V1::UsersController < ApplicationController
  allow_unauthenticated_access only: [ :index ]

  def index
    users = User.page(params[:page]).per(params[:per_page] || 25)

    render json: users, status: :ok
  end

  def update
    if current_user.update(user_params)
      render json: current_user, status: :ok
    else
      render json: { errors: current_user.errors }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :balance)
  end
end
