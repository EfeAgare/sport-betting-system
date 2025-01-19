module ErrorHandling
  extend ActiveSupport::Concern
  include Validatable

  included do
    # Rescue from specific exceptions first
    rescue_from StandardError do |exception|
      # Catch any errors derived from StandardError (default Ruby errors)
      # This acts as a catch-all for unexpected errors
      case exception
      when ActionController::RoutingError
        # Provide a more user-friendly message for routing errors
        respond(:not_found, 404, "The requested resource could not be found. Please check the URL or contact support.")
      when ActiveRecord::RecordNotFound
        respond(:not_found, 404, exception.message || "Resource not found.")
      when ActiveRecord::RecordInvalid
        respond(:unprocessable_entity, 422, exception.record.errors.full_messages.join(", "))
      when ActionController::ParameterMissing
        respond(:bad_request, 400, "Missing parameter: #{exception.param}")
      when UnauthorizedError
        respond(:unauthorized, 401, exception.message || "You are not authorized to perform this action.")
      when InsufficientBalanceError
        respond(:unprocessable_entity, 422, exception.message || "Your balance is insufficient to place this bet.")
      when InvalidBetError
        respond(:unprocessable_entity, 422, exception.message || "Invalid bet details provided.")
      when ValidationError
        respond(:unprocessable_entity, 422, exception.message)
      else
        # Fallback for all other errors that do not match specific cases.
        # This is the "catch-all" handler for any other unhandled errors.
        # It returns a 500 Internal Server Error with the exception's message.
        respond(:internal_server_error, 500, exception.message)
      end
    end
  end

  private

  # Helper method to standardize error responses
  def respond(error_code, status, message)
    # Ensures the message is a string, joining array elements if necessary
    error_message = message.is_a?(Array) ? message.join(", ") : message
    render json: { error: { code: error_code, message: error_message } }, status: status
  end
end
