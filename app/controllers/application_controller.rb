class ApplicationController < ActionController::API
  include Authenticable
  include ErrorHandling
  include Helpers

  before_action :set_version

  private

  def set_version
    version = request.headers
    @api_version = version || "1" # Default to version 1 if not specified
  end
end
