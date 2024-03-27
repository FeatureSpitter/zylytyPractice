# frozen_string_literal: true

require 'test_helper'

class CategoryThreadsControllerTest < ActionDispatch::IntegrationTest
  include ::JwtHelper

  setup do
    @user = User.create(username: 'testuser', email: 'test@email.email', password: 'password')
    @category = Category.create(name: 'Test Category')
    @session_token = generate_jwt_token(@user)
    @header = { 'Cookie' => "sessionId=#{@session_token}" }
    @category_thread = create(:category_thread, category: @category, author: @user)
    @admin_header = { 'Authorization' => ENV['ADMIN_API_KEY'] }
  end

  test "should create thread" do
    params = { category: @category.name, title: 'New Discussion', openingPost: 'This is a new discussion' }
    assert_difference('CategoryThread.count') do
      post category_threads_url, params: params, headers: @header, as: :json
    end

    assert_response :created
  end

  test "should list threads" do
    get category_threads_url(categories: @category.name), headers: @header, as: :json
    assert_response :success
    assert_not_nil response.body
  end

  test "should not create category thread without user" do
    assert_no_difference('CategoryThread.count') do
      params = { category_thread: { title: 'New Thread', user_id: nil, category_id: @category.id } }
      post category_threads_url, params: params, as: :json
    end

    assert_response :unauthorized
  end

  test "should not update category thread with invalid title" do
    params = { category: @category.name, title: '', openingPost: 'This is a new discussion' }
    post category_threads_url(@category_thread), params: params, headers: @header, as: :json
    assert_response :bad_request
  end

  test "should not update category thread with non-existent category" do
    params = { category_thread: { category_id: -1 } }
    post category_threads_url(@category_thread), params: params, headers: @header, as: :json
    assert_response :not_found
  end

  test "should show category thread with expected structure" do
    list = create_list(:category_thread, 20, category: @category)
    get category_threads_url(categories: @category.name, newest_first: true), headers: @header, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    subject = list.last
    first_record = json_response.first

    assert_equal subject.title, first_record['title']
    assert_equal subject.id, first_record['id']
    assert_equal subject.category_id, first_record['category_id']
    assert_equal subject.author_id, first_record['author_id']
    assert_equal json_response.count, 10
  end

  test "should delete thread with valid token" do
    delete category_thread_path(@category_thread.id), headers: @admin_header
    assert_response :no_content
  end

  test "should return unauthorized with invalid token" do
    delete category_thread_path(@category_thread.id), headers: @header.merge("Authorization" => "invalid")
    assert_response :unauthorized
  end

  test "should return not found for non-existing thread" do
    delete category_thread_path(@category_thread.id + 10), headers: @admin_header
    assert_response :not_found
  end
end
