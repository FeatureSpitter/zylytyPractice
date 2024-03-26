# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :category_threads, foreign_key: 'author_id', inverse_of: :author, dependent: :destroy
  has_many :thread_posts, foreign_key: 'author_id', inverse_of: :author, dependent: :destroy
  validates :username, :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }
end
