# frozen_string_literal: true

json.searchResults do
  @query.map do |category_thread_id, thread_posts|
    json.set! category_thread_id do
      json.array!(thread_posts.map{ |post| post.formatted_search_result_text(@query_text) })
    end
  end
end
