class Api::V1::SessionsController < ApplicationController
  allow_unauthenticated_access except: [ :destroy ]

  def create
    user = User.find_by(email: user_params[:email])

    if user&.authenticate(user_params[:password])
      token = ::GenerateToken.new.call(user)
      render json: {
        success: true,
        token: token,
        user: user_data(user)
      }, status: :created
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def destroy
    jti = payload_data["jti"]
    if jti.present?
      JwtBlacklist.create(jti: jti)
      render json: { message: "Logged out successfully" }, status: :ok
    else
      render json: { error: "Invalid token" }, status: :unprocessable_entity
    end
  end

  private

  def user_data(user)
    user.as_json(only: [ :id, :email, :username, :created_at, :updated_at ])
  end

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
