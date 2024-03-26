# frozen_string_literal: true

require "test_helper"

class CategoryThreadTest < ActiveSupport::TestCase
  def setup
    @user = User.create(username: 'testuser', email: 'test@email.email', password: 'password')
    @category = Category.create(name: 'Test Category')

    @category_thread = CategoryThread.new(title: 'Test Thread', author: @user, category: @category)
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
end
