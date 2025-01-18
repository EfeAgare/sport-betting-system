class Api::V1::UsersController < ApplicationController
  allow_unauthenticated_access only: [ :index ]

  def index
    validate_pagination!
    users = User.page(params[:page]).per(params[:per_page] || 25)

    render json: users, meta: pagination_meta(users),  status: :ok
  end

  def update
    UserValidator.new(user_params).validate!
    current_user.update!(user_params)
    render json: current_user, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:username, :balance)
  end
end
