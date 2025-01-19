class ErrorsController < ApplicationController
  allow_unauthenticated_access
  def routing_error
    render json: { error: "Not Found", message: "The requested resource could not be found. Please check the URL or contact support." }, status: 404
  end
end
