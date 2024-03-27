# frozen_string_literal: true

class ThreadPost < ApplicationRecord
  default_scope { order(created_at: :asc) }
  belongs_to :category_thread
  belongs_to :author, class_name: 'User', inverse_of: :thread_posts
  validates :text, presence: true

  def self.full_text_search(query)
    sanatized_query = query.gsub(/[^a-zA-Z0-9\s]/, '')
    where("to_tsvector('english', text) @@ plainto_tsquery('english', ?)", sanatized_query)
  end

  def formatted_search_result_text(query)
    text_tokens = text.scan(/(?:\b[\w'-]+(?:\b))|(?: - )/)
    text_tokens_lowercase = text_tokens.map(&:downcase).map(&:strip)
    text_split = text.split(' ')
    query_tokens = query.downcase.scan(/(?:\b[\w'-]+(?:[.,!?]|\b))|(?: - )/)

    matching_indices = query_tokens.flat_map do |token|
      text_tokens_lowercase.each_index.select { |i| text_tokens_lowercase[i].match(/^#{token}$/) }
    end.uniq.sort

    if matching_indices.empty?
      return "Query not found in text."
    end

    start_index = [matching_indices.first - 3, 0].max
    end_index = matching_indices.last + 3
    context_segment = text_split[start_index..end_index].join(' ')

    "...#{context_segment}..."
  end
end
