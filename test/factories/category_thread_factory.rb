# frozen_string_literal: true

FactoryBot.define do
  factory :category_thread do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    user
    category
  end
end
