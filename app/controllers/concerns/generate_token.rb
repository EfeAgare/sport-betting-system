# frozen_string_literal: true

class GenerateToken
  attr_accessor :user_id, :token

  # Main entry point to generate a token for a given user
  def call(user)
    @user_id = user.id
    @token = generate_token
  end

  private

  # Generates the JWT token using the payload, secret, and algorithm
  def generate_token
    JWT.encode(payload, hmac_secret, hmac_algorithm)
  rescue StandardError => e
    Rails.logger.debug e.message
  end

  # Constructs the payload for the JWT token
  def payload
    {
      sub: @user_id,      # Subject: the user ID
      jti: jwt_id,        # JWT ID: unique identifier for the token
      iat: issued_at      # Issued at: timestamp when the token was created
    }
  end

  # Generates a unique JWT ID based on the HMAC secret and issued time
  def jwt_id
    @jwt_id ||= Digest::MD5.hexdigest([ hmac_secret, issued_at ].join(":").to_s)
  end

  # Retrieves the HMAC secret key from the environment variables
  def hmac_secret
    ENV["HMAC_SECRET"]
  end

  # Retrieves the HMAC algorithm from the environment variables
  def hmac_algorithm
    ENV["HMAC_ALGORITHM"]
  end

  # Retrieves the current timestamp to mark the token's creation time
  def issued_at
    @issued_at ||= Time.current.to_i
  end
end
