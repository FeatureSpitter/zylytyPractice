# frozen_string_literal: true

class BaseApiController < ApplicationController
  rescue_from StandardError, with: :truncated_error

  def jwt_secret
    Rails.application.credentials.jwt_secret
  end

  def issue_token(user)
    JWT.encode({ user_id: user.id, exp: Time.now + 30.min }, jwt_secret, 'HS256')
  end

  def decoded_token
    JWT.decode(token, jwt_secret, true, { algorithm: 'HS256' })
  rescue JWT::DecodeError
    [{ error: "Invalid Token" }]
  end

  protected

  def truncated_error(error)
    error_info = {
      error: "Internal Server Error",
      exception: "#{error.class.name} : #{error.message}",
    }
    error_info[:trace] = e.backtrace if Rails.env.development?
    render json: error_info.to_json, status: :internal_server_error
  end
end
