# frozen_string_literal: true

require "test_helper"

class ThreadPostsControllerTest < ActionDispatch::IntegrationTest
  include ::JwtHelper

  setup do
    @user = create(:user)
    @category_thread = create(:category_thread, author: @user)
    @session_token = generate_jwt_token(@user)
    @headers = { "Cookie" => "sessionId=#{@session_token}" }
  end

  test "should create thread posts" do
    assert_difference("ThreadPost.count", 2) do
      post posts_url, params: {
        threadId: @category_thread.id,
        posts: [
          { text: "Post 1" },
          { text: "Post 2" }
        ]
      }, headers: @headers, as: :json
    end

    assert_response :created
  end

  test "post posts_url returns 404 if category thread does not exist" do
    post posts_url, params: {
      threadId: 9999,
      posts: [
        { text: "Post 1" },
        { text: "Post 2" }
      ]
    }, headers: @headers, as: :json

    assert_response :not_found
  end

  test "should list thread posts in ascending order" do
    @category_thread.thread_posts.first.update(created_at: 20.minutes.ago)
    older_post = create(:thread_post, category_thread: @category_thread, text: "First post", created_at: 10.minutes.ago)
    newer_post = create(:thread_post, category_thread: @category_thread, text: "Second post", created_at: 5.minutes.ago)

    get posts_url(thread_id: @category_thread.id), headers: @headers, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)

    assert_equal older_post.text, json_response["posts"].first["text"]
    assert_equal newer_post.text, json_response["posts"].second["text"]
  end

  test "get posts_url returns 404 if category thread does not exist" do
    get posts_url(thread_id: 9999), headers: @headers, as: :json
    assert_response :not_found
  end

  test "get posts_url returns 400 if category thread id is not provided" do
    get posts_url, headers: @headers, as: :json
    assert_response :bad_request
  end

  test "search returns expected formatted results" do
    category_thread_2 = create(:category_thread, author: @user)
    create(:thread_post, text: "This one amazing day, Smith was actually a banana. What the hell? I mean common.", category_thread: category_thread_2)
    create(:thread_post, text: "This is astonishing happened - but Smith was actually a banana. This surreal transformation is unique", category_thread: @category_thread)
    create(:thread_post, text: "This thread is not expected to be in the results", category_thread: @category_thread)
    get search_url(text: 'but smith was actually a banana'), headers: @headers, as: :json

    assert_response :success

    expected_response = {
      "searchResults" => {
        @category_thread.id.to_s => ["...astonishing happened - but Smith was actually a banana. This surreal transformation..."],
        category_thread_2.id.to_s => ["...one amazing day, Smith was actually a banana. What the hell?..."]
      }
    }

    assert_equal expected_response, JSON.parse(@response.body)
  end
end
