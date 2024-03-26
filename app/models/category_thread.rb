# frozen_string_literal: true

class CategoryThread < ApplicationRecord
  belongs_to :category
  belongs_to :author, class_name: 'User', inverse_of: :category_threads
  has_many :thread_posts, dependent: :destroy

  validates :title, presence: true
  accepts_nested_attributes_for :thread_posts
end
