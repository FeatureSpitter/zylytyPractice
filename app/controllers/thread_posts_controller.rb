# frozen_string_literal: true

class ThreadPostsController < BaseApiController
  before_action :set_category_thread

  def create
    post_params.each do |post|
      @category_thread.thread_posts.create!(post)
    end

    head :created
  end

  def index
    @thread_posts = @category_thread.thread_posts
  end

  private

  def set_category_thread
    return head :bad_request unless params[:threadId] || params[:thread_id]

    @category_thread = CategoryThread.find(params[:threadId] || params[:thread_id])
  end

  def post_params
    params.require(:posts).map do |post|
      post.permit(:text).merge(author_id: current_user.id)
    end
  end
end
