# frozen_string_literal: true

class CategoriesController < BaseApiController
  before_action :authenticate_admin, only: :create

  def index
    @categories = Category.all.pluck(:name)
    render json: @categories
  end

  def create
    categories_params.each do |category_name|
      Category.create!(name: category_name)
    end
    head :created
  rescue StandardError
    head :bad_request
  end

  private

  def categories_params
    params.require(:categories)
  end
end
