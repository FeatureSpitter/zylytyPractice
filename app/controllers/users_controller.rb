# frozen_string_literal: true

class UsersController < BaseApiController
  skip_before_action :authorize_request

  def login
    @user = User.find_by(username: params[:username])
    if @user&.authenticate(params[:password])
      @token = issue_token(@user)
      response.set_cookie('sessionId', @token)
      render 'users/login', status: :ok
    else
      head :unauthorized
    end
  end

  def register
    @user = User.new(user_params)
    if @user.save
      head :created
    else
      head registration_error_status
    end
  end

  private

  def registration_error_status
    if @user.errors.messages.values.any? { |msg| msg.include?('has already been taken') }
      :teapot
    else
      :bad_request
    end
  end

  def user_params
    params.permit(:username, :email, :password)
  end
end
