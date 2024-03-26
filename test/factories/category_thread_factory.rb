# frozen_string_literal: true

FactoryBot.define do
  factory :category_thread do
    title { Faker::Lorem.sentence }
    association :author, factory: :user
    association :category
  end
end
