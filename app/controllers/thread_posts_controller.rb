# frozen_string_literal: true

class ThreadPostsController < BaseApiController
  before_action :set_category_thread, only: %i[create index]

  def create
    post_create_params.each do |post|
      @category_thread.thread_posts.create!(post)
    end

    head :created
  end

  def index
    @thread_posts = @category_thread.thread_posts
  end

  def search
    @query_text = search_params[:text]
    @query = ThreadPost.full_text_search(@query_text).group_by(&:category_thread_id).sort_by { |id, _| id }

    head :not_found if @query.empty?
  end

  private

  def set_category_thread
    return head :bad_request unless params[:threadId] || params[:thread_id]

    @category_thread = CategoryThread.find(params[:threadId] || params[:thread_id])
  end

  def post_create_params
    params.require(:posts).map do |post|
      post.permit(:text).merge(author_id: current_user.id)
    end
  end

  def search_params
    params.permit(:text)
  end
end
