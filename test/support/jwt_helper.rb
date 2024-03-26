# frozen_string_literal: true

module JwtHelper
  def generate_jwt_token(user)
    payload = { user_id: user.id, exp: Time.now.to_i + 1.hour }
    JWT.encode(payload, Rails.application.credentials.jwt_secret, 'HS256')
  end
end
