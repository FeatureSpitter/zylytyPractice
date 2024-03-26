# frozen_string_literal: true

class ThreadPostTest < ActiveSupport::TestCase
  def setup
    @user = create(:user)
    @category = create(:category)
    @category_thread = create(:category_thread, author: @user, category: @category)
  end

  def test_thread_post_creation_with_valid_attributes
    thread_post = ThreadPost.new(text: "This is a test post", category_thread: @category_thread, author: @user)

    assert thread_post.valid?
  end

  def test_thread_post_should_not_be_valid_without_text
    thread_post = ThreadPost.new(category_thread: @category_thread, author: @user)

    assert_not thread_post.valid?
    assert_includes thread_post.errors[:text], "can't be blank"
  end

  def test_thread_post_belongs_to_category_thread
    thread_post = ThreadPost.create!(text: "Belongs to category thread test", category_thread: @category_thread, author: @user)

    assert_equal @category_thread, thread_post.category_thread
  end

  def test_thread_post_belongs_to_user_as_author
    thread_post = ThreadPost.create!(text: "Belongs to user as author test", category_thread: @category_thread, author: @user)

    assert_equal @user, thread_post.author
  end
end
