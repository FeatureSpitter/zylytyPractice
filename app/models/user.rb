# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :category_threads, foreign_key: 'author_id', inverse_of: :author, dependent: :destroy
  has_many :thread_posts, foreign_key: 'author_id', inverse_of: :author, dependent: :destroy
  validates :username, :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }
  before_create :generate_admin_auth_token

  def self.import_users(csv_file)
    parsed_csv = CSV.parse(csv_file, headers: true)

    errors = []
    parsed_csv.each_with_index do |row, index|
        user = new(row.to_h)
        unless user.save
          errors << "Row #{index + 1}: #{user.errors.full_messages.join(', ')}"
        end
    rescue ActiveRecord::RecordInvalid => e
        errors << "Row #{index + 1}: #{e.message}"
    end

    errors
  end
end
