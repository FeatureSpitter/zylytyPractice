# frozen_string_literal: true

class CategoryThreadsController < BaseApiController
  # POST /threads
  def create
    @category = Category.find_by!(name: params[:category])
    @category_thread = @category.category_threads.create!(category_thread_params)

    head :created
  end

  # GET /threads
  def index
    # Convert to array if single value
    category_names = [params[:categories]].flatten
    categories = category_names.map { |name| Category.find_by!(name: name) }

    @threads = CategoryThread.includes(:category)
    @threads = @threads.where(category: categories)
    @threads = @threads.where(title: params[:title]) if params[:title]
    @threads = @threads.where(author: params[:author]) if params[:author]
    @threads = @threads.order(created_at: :desc) if params[:newest_first] == 'true'
    @threads = @threads.paginate(page: params[:page], per_page: params[:page_size] || 10)

    render json: @threads
  end

  private

  def category_thread_params
    thread_post_attributes = { text: params[:openingPost], author: current_user }
    params.permit(:title).merge(author: current_user, thread_posts_attributes: [thread_post_attributes])
  end
end
