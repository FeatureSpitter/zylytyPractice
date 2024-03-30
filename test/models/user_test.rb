# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(username: 'testuser', email: 'test@example.com', password: 'password')
  end

  test 'valid user' do
    assert @user.valid?
  end

  test 'invalid without username' do
    @user.username = nil
    assert_not @user.valid?, 'user is valid without a username'
    assert_not_nil @user.errors[:username], 'no validation error for username present'
  end

  test 'invalid without email' do
    @user.email = nil
    assert_not @user.valid?
    assert_not_nil @user.errors[:email]
  end

  test 'email must be unique' do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
    assert_not_nil duplicate_user.errors[:email]
  end

  test 'username must be unique' do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
    assert_not_nil duplicate_user.errors[:username]
  end

  test 'email validation should accept valid addresses' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test 'email validation should reject invalid addresses' do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test 'password should have a minimum length' do
    @user.password = 'a' * 5
    assert_not @user.valid?
  end

  test 'associated category_threads are destroyed' do
    @user.save
    @user.category_threads.create!(title: 'Test Thread', category: create(:category))
    assert_difference 'CategoryThread.count', -1 do
      @user.destroy
    end
  end

  test 'associated thread_posts are destroyed' do
    @user.save
    create(:thread_post, text: 'Test Post', author: @user, category_thread: create(:category_thread))
    assert_difference 'ThreadPost.count', -1 do
      @user.destroy
    end
  end

  test "import_users should create users from CSV file" do
    csv_data = <<~CSV
      username,password,email
      user1,password1,user1@example.com
      user2,password2,user2@example.com
    CSV

    csv_file = StringIO.new(csv_data)

    assert_difference('User.count', 2) do
      User.import_users(csv_file)
    end
  end

  test "import_users_should_handle_malformed_and_valid_CSV_file" do
    user_count = User.count
    csv_file = file_fixture("malformed_csv.csv")
    file = File.open(csv_file)

    User.import_users(file)

    assert_equal user_count, User.count, "User count should not change"
    file.close
  end
end
