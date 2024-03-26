# frozen_string_literal: true

opening_post = @thread_posts.first

json.extract! @category_thread, :id, :title, :created_at
json.author @category_thread.author.username
json.category @category_thread.category.name
json.extract! @category_thread, :title
json.text opening_post.text
json.posts @thread_posts[1..].map do |post|
  json.extract! post, :text, :created_at
  json.author post.author.username
end
