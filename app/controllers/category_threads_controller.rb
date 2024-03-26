# frozen_string_literal: true

class CategoryThreadsController < BaseApiController
  # POST /threads
  def create
    @category = Category.find_by!(name: params[:category])
    @category_thread = @category.category_threads.create!(category_thread_params.merge(author: current_user))

    @thread = @category.category_threads.create(category_thread_params.merge(user: current_user))

    if @thread.persisted?
      head :created
    else
      render json: @thread.errors, status: :bad_request
    end
  end

  # GET /threads
  def index
    category_names = [params[:categories]].flatten
    return head(:bad_request) if category_names.any? { |name| Category.find_by(name: name).nil? }

    @threads = CategoryThread.includes(:category)
    @threads = @threads.where(category: { name: category_names })
    @threads = @threads.where(title: params[:title]) if params[:title]
    @threads = @threads.where(author: params[:author]) if params[:author]
    @threads = @threads.order(created_at: :desc) if params[:newest_first] == 'true'
    @threads = @threads.paginate(page: params[:page], per_page: params[:page_size] || 10)

    render json: @threads
  end

  private

  def category_thread_params
    params.permit(:title)
  end
end
