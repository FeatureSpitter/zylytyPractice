# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @valid_params = {
      username: 'newuser',
      email: 'newuser@example.com',
      password: 'securepassword'
    }

    @invalid_params = {
      username: '', # Invalid because it's blank
      email: 'invalidemail',
      password: '' # Invalid because it's blank
    }

    # Assume `existinguser` is a username already taken
    User.create(username: 'existinguser', email: 'existing@example.com', password: 'password123')
    @duplicate_params = {
      username: 'existinguser',
      email: 'user@example.com',
      password: 'password123'
    }
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
    assert_no_difference('User.count') do
      post register_url, params: @duplicate_params
    end
    assert_response :teapot
  end
end
