# frozen_string_literal: true

class CategoryThreadsController < BaseApiController
  before_action :authenticate_admin, only: :destroy

  # POST /threads
  def create
    @category = Category.find_by!(name: params[:category])
    @category_thread = @category.category_threads.create!(category_thread_params)

    head :created
  end

  # GET /threads
  def index
    # Convert to array if single value
    return head :bad_request if params[:categories].empty?

    category_names = params[:categories].is_a?(Array) ? params[:categories] : params[:categories].split(',').map(&:strip)
    categories = ::Category.where(name: category_names)

    page = params[:page].to_i + 1
    per_page = params[:page_size] || 10

    @category_threads = CategoryThread.includes(:category).where(category: categories)
    @category_threads = @category_threads.where(title: params[:title]) if params[:title]
    @category_threads = @category_threads.where(author: params[:author]) if params[:author]
    @category_threads = @category_threads.order(created_at: :desc) if params[:newest_first] == 'true'
    @category_threads = @category_threads.paginate(page: page, per_page: per_page)

    @category_threads
  end

  # DELETE /threads/:id
  def destroy
    @category_thread = CategoryThread.find(params[:id])

    head :no_content if @category_thread.destroy
  end

  private

  def category_thread_params
    thread_post_attributes = { text: params[:openingPost][:text], author: current_user }
    params.permit(:title).merge(author: current_user, thread_posts_attributes: [thread_post_attributes])
  end
end
