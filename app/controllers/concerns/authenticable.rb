module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :authenticate_user!, **options
    end
  end

  private

  def authenticate_user!
    raise UnauthorizedError, "Authorization token is missing" unless token
    raise UnauthorizedError, "Invalid or expired token" unless decoded_token
    raise UnauthorizedError, "User not found" unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: payload_data["sub"]) if token && decoded_token
  end

  def token
    @token ||= request.headers["Authorization"].to_s.split(" ").last
  end

  def decoded_token
    @decoded_token ||= begin
      token_data = JWT.decode(token, hmac_secret, true, decode_options)
      jti = token_data.dig(0, "jti")
      return nil if JwtBlacklist.exists?(jti: jti)

      token_data
    end
  rescue JWT::DecodeError
    nil
  end

  def payload_data
    @payload_data ||= decoded_token&.reduce({}, :merge)
  end

  def hmac_secret
    ENV["HMAC_SECRET"]
  end

  def decode_options
    {
      algorithm: ENV["HMAC_ALGORITHM"],
      verify_jti: true
    }
  end
end
