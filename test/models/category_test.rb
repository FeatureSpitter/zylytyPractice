# frozen_string_literal: true

require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test 'valid category' do
    category = Category.new(name: 'Education')
    assert category.valid?
  end

  test 'invalid without name' do
    category = Category.new(name: nil)
    assert_not category.valid?, 'category is valid without a name'
    assert_not_nil category.errors[:name], 'no validation error for name present'
  end

  test 'name should be unique' do
    Category.create!(name: 'UniqueCategory')
    category = Category.new(name: 'UniqueCategory')
    assert_not category.valid?, 'category is valid with a duplicate name'
  end
end
