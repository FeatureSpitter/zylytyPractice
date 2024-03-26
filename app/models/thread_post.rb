# frozen_string_literal: true

class ThreadPost < ApplicationRecord
  default_scope { order(created_at: :asc) }
  belongs_to :category_thread
  belongs_to :author, class_name: 'User', inverse_of: :thread_posts
  validates :text, presence: true
end
