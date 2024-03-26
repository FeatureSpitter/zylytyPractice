# frozen_string_literal: true

FactoryBot.define do
  factory :thread_post do
    text { "This is a test post" }
    association :category_thread
    association :author, factory: :user
  end
end
