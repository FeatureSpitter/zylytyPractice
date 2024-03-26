# frozen_string_literal: true

FactoryBot.define do
  factory :category_thread do
    title { Faker::Lorem.sentence }
    association :author, factory: :user
    association :category

    after(:create) do |category_thread|
      create_list(:thread_post, 1, category_thread: category_thread, author: category_thread.author)
    end
  end
end
