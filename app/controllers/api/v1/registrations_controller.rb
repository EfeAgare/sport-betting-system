class Api::V1::RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def create
    user = User.new(user_params)

    if user.save
      token = ::GenerateToken.new.call(user)
      render json: {
        success: true,
        token: token,
        user: user_data(user)
      }, status: :created
    else
      render json: { success: false, errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :username)
  end

  def user_data(user)
    user.as_json(only: [ :id, :email, :username, :created_at, :updated_at ])
  end
end
