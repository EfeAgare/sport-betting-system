
module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

    # Custom domain-specific errors
    rescue_from UnauthorizedError, with: :handle_unauthorized
    rescue_from InsufficientBalanceError, with: :handle_insufficient_balance
    rescue_from InvalidBetError, with: :handle_invalid_bet
    rescue_from ValidationError, with: :validation_error

    # Fallback for all other errors
    rescue_from StandardError, with: :handle_internal_server_error
  end

  private

  # Handle ActiveRecord::RecordNotFound
  def handle_record_not_found(exception)
    render_error(
      code: "not_found",
      message: exception.message || "Resource not found.",
      status: :not_found
    )
  end

  # Handle ActiveRecord::RecordInvalid
  def handle_record_invalid(exception)
    render_error(
      code: "unprocessable_entity",
      message: exception.record.errors.full_messages.join(", "),
      status: :unprocessable_entity
    )
  end

  # Handle ActionController::ParameterMissing
  def handle_parameter_missing(exception)
    render_error(
      code: "bad_request",
      message: "Missing parameter: #{exception.param}",
      status: :bad_request
    )
  end

  # Handle UnauthorizedError
  def handle_unauthorized(exception)
    render_error(
      code: "unauthorized",
      message: exception.message || "You are not authorized to perform this action.",
      status: :unauthorized
    )
  end

  # Handle InsufficientBalanceError
  def handle_insufficient_balance(exception)
    render_error(
      code: "unprocessable_entity",
      message: exception.message || "Your balance is insufficient to place this bet.",
      status: :unprocessable_entity
    )
  end

  # Handle InvalidBetError
  def handle_invalid_bet(exception)
    render_error(
      code: "unprocessable_entity",
      message: exception.message || "Invalid bet details provided.",
      status: :unprocessable_entity
    )
  end

  # Handle StandardError (fallback)
  def handle_internal_server_error(exception)
    # Log error details for debugging
    logger.error("Internal Server Error: #{exception.message}")
    logger.error(exception.backtrace.join("\n"))

    render_error(
      code: "internal_server_error",
      message: "Something went wrong. Please try again later.",
      status: :internal_server_error
    )
  end

  # Helper method to standardize error responses
  def render_error(code:, message:, status:)
    render json: { error: { code: code, message: message } }, status: status
  end

  def validation_error(error)
    render_error(
      code: "unprocessable_entity",
      message: exception.message.join(", "),
      status: :unprocessable_entity
    )
  end
end
