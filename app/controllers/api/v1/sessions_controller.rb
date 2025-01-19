class Api::V1::SessionsController < ApplicationController
  allow_unauthenticated_access except: [ :destroy ]

  # Limit login attempts to 5 within 1 minute
  rate_limit to: 5, within: 1.minute, only: :create, with: -> {
    response.headers["Retry-After"] = 240.to_s
    render json: { error: "Too many login attempts. Please try again later." }, status: :too_many_requests
  }

  # Authenticates user and generates a token if credentials are valid
  def create
    UserValidator.new(user_params, required_fields: [ :email, :password ]).validate!
    user = User.find_by(email: user_params[:email])

    if user&.authenticate(user_params[:password])
      # Generate a token for the authenticated user
      token = ::GenerateToken.new.call(user)
      render json: {
        success: true,
        token: token,
        user: user_data(user)
      }, status: :created
    else
      # If credentials are invalid, return an error
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  # Logs out the user by blacklisting the current JWT token
  def destroy
    jti = payload_data["jti"]
    if jti.present?
      # Add the JWT ID to the blacklist to invalidate the session
      JwtBlacklist.create(jti: jti)
      render json: { message: "Logged out successfully" }, status: :ok
    else
      # If the token is invalid or missing, return an error
      render json: { error: "Invalid token" }, status: :unprocessable_entity
    end
  end

  private

  # Returns a subset of user data to include in the response
  def user_data(user)
    user.as_json(only: [ :id, :email, :username, :created_at, :updated_at ])
  end

  # Permits email and password parameters for user login
  def user_params
    params.require(:user).permit(:email, :password)
  end
end
