# frozen_string_literal: true

require "test_helper"

class CategoryThreadTest < ActiveSupport::TestCase
  def setup
    @user = User.create(username: 'testuser', email: 'test@email.email', password: 'password')
    @category = Category.create(name: 'Test Category')

    @category_thread = CategoryThread.new(title: 'Test Thread', author: @user, category: @category)
    @thread_post = create(:thread_post, category_thread: @category_thread, author: @user)
  end

  test 'valid category thread' do
    assert @category_thread.valid?
  end

  test 'invalid without title' do
    @category_thread.title = nil
    assert_not @category_thread.valid?, 'CategoryThread is valid without a title'
    assert_not_nil @category_thread.errors[:title], 'No validation error for title present'
  end

  test 'should belong to a category' do
    assert_respond_to @category_thread, :category, 'CategoryThread does not belong to a category'
    assert_equal @category, @category_thread.category, 'CategoryThread category is not as expected'
  end

  test 'should belong to a user as author' do
    assert_respond_to @category_thread, :author, 'CategoryThread does not belong to a user'
    assert_equal @user, @category_thread.author, 'CategoryThread author is not as expected'
  end

  test 'should have many thread posts' do
    assert_respond_to @category_thread, :thread_posts, 'CategoryThread does not have many thread posts'
    assert_includes @category_thread.thread_posts, @thread_post, 'ThreadPost is not included in CategoryThread thread_posts'
  end

  test 'should destroy thread posts when category thread is destroyed' do
    assert_difference 'ThreadPost.count', -1 do
      @category_thread.destroy
    end
  end
end
