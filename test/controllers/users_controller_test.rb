# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_params = { username: 'testuser', email: 'test@testing.test', password: 'password' }
    @user_login = { username: 'testuser', password: 'password' }
    @user = User.create(@user_params)
    @valid_params = { username: 'validuser', email: 'valid@user.email', password: 'password' }

    @invalid_params = {
      username: '', # Invalid because it's blank
      email: 'invalidemail',
      password: '' # Invalid because it's blank
    }
  end

  test "should login user successfully" do
    post login_url, params: @user_login.to_json, headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
    assert_response :ok
    assert_not_nil response.cookies['sessionId']
  end

  test "should register user successfully" do
    assert_difference('User.count') do
      post register_url, params: @valid_params
    end
    assert_response :created
  end

  test "should respond with bad request on invalid params" do
    assert_no_difference('User.count') do
      post register_url, params: @invalid_params
    end
    assert_response :bad_request
  end

  test "should respond with teapot status when username already taken" do
    User.create(@user_params)
    assert_no_difference('User.count') do
      post register_url, params: @user_params
    end
    assert_response :teapot
  end

  test "handles internal server error" do
    # Simulating an internal error by expecting an undefined method call on nil
    User.stubs(:find_by).raises(StandardError.new("Simulated failure")) do
      post login_url, params: @login_params
      assert_response :internal_server_error
      json_response = JSON.parse(response.body)
      assert_equal 'Internal Server Error', json_response['error']
    end
  end
end
