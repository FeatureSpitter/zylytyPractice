# frozen_string_literal: true

class CategoryThread < ApplicationRecord
  belongs_to :category
  belongs_to :author, class_name: 'User', inverse_of: :category_threads

  validates :title, presence: true
end
