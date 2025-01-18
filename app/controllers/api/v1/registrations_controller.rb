class Api::V1::RegistrationsController < ApplicationController
  allow_unauthenticated_access

  # Limit signup attempts to 3 within 1 minute
  rate_limit to: 3, within: 1.minute, only: :create, with: -> { render json: { error: "Too many signup attempts. Please try again later." }, status: :too_many_requests }

  # Registers a new user and returns a token upon successful creation
  def create
    RegistrationValidator.new(user_params).validate!
    user = User.new(user_params)

    # Saves the user and raises an exception if validation fails
    user.save!

    # Generate a token for the newly created user
    token = ::GenerateToken.new.call(user)

    # Return the success response with user data and token
    render json: {
      success: true,
      token: token,
      user: user_data(user)
    }, status: :created
  end

  private

  # Permits only necessary parameters for user registration
  def user_params
    params.require(:user).permit(:email, :password, :username)
  end

  # Returns a subset of user data to include in the response
  def user_data(user)
    user.as_json(only: [ :id, :email, :username, :created_at, :updated_at ])
  end
end
