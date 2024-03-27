# frozen_string_literal: true

require 'test_helper'

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  include ::JwtHelper

  setup do
    @category = Category.create(name: "Valid Category")
    @user = create(:user)
    @session_token = generate_jwt_token(@user)
    @admin_header = { 'Authorization' => ENV['ADMIN_API_KEY'] }
  end

  test "should get index" do
    get categories_url, headers: { 'Cookie' => "sessionId=#{@session_token}" }
    assert_response :success
    assert_includes @response.body, @category.name
  end

  test "should create category with valid admin API key" do
    assert_difference('Category.count') do
      post categories_url, params: { categories: ['NewCategory'] }, headers: @admin_header
    end
    assert_response :created
  end

  test "should not create category without admin API key" do
    assert_no_difference('Category.count') do
      post categories_url, params: { categories: ['UnauthorizedCategory'] }, headers: { 'Cookie' => "sessionId=#{@session_token}" }
    end
    assert_response :unauthorized
  end

  test "should not create category with duplicate name" do
    assert_no_difference('Category.count') do
      post categories_url, params: { categories: ['Valid Category'] }, headers: @admin_header
    end
    assert_response :bad_request
  end

  test "should delete category with valid token and non-default category" do
    delete category_path(category: @category.name), headers: @admin_header
    assert_response :success
  end

  test "should return unauthorized with invalid token" do
    delete category_path(category: @category.name), headers: { 'Cookie' => "sessionId=#{@session_token}", 'Authorization' => 'invalid_token' }
    assert_response :unauthorized
  end

  test "should return bad request for default category" do
    delete category_path(category: "Default"), headers: @admin_header
    assert_response :bad_request
  end

  test "should return bad request for non-existing category" do
    delete category_path(category: "Non-Existing Category"), headers: @admin_header
    assert_response :bad_request
  end
end
