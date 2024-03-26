# frozen_string_literal: true

json.threads @category_threads.map do |thread|
  json.extract! thread, :id, :title, :username, :created_at
  json.category thread.category.name
  json.author thread.author.username
end
