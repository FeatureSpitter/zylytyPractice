# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :category_threads, foreign_key: 'author_id', inverse_of: :author, dependent: :destroy
  has_many :thread_posts, foreign_key: 'author_id', inverse_of: :author, dependent: :destroy
  validates :username, :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }

  def self.import_users(csv_file)
    parsed_csv = CSV.parse(csv_file, headers: true)
    hashed_csv = parsed_csv.map(&:to_h)
    users = []
    hashed_csv.each do |row|
      row = row.transform_keys { |key| key == 'e-mail' ? :email : key.to_sym }
      users << User.new(row)
    end

    ActiveRecord::Base.transaction do
      import_action = User.import users, validate: true

      raise ActiveRecord::Rollback if import_action.failed_instances.present?
    end
  end
end
