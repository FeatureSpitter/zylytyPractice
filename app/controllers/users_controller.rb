# frozen_string_literal: true

class UsersController < BaseApiController
  skip_before_action :authorize_request, except: :import
  before_action :authenticate_admin, only: :import

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

  def import
    unless params[:file].present? && params[:file].content_type == "text/csv"
      render json: { error: 'Bad Request: Please provide a valid CSV file' }, status: :bad_request
      return
    end

    file = params[:file].read
    params[:file].close
    return head :ok if file.blank?

    errors = User.import_users(file)

    if errors.any?
      render json: { errors: errors }, status: :bad_request
    elsif errors.empty? && file.empty?
      head :ok
    else
      head :created
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
