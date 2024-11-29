class ProductsController < ApplicationController
  rescue_from CSV::MalformedCSVError, with: :csv_invalid_response

  before_action :validate_params, only: :import

  def index
    @products = Product.all.includes(:category)
  end

  def show
    @product = Product.find(params[:id])
  end

  def import
    @records = ProductImportService.new(params[:csv].tempfile).process
  end

  private

  def validate_params
    validation = validation_schema.call(params.to_unsafe_h)
    render json: { error: { csv: 'file is missing' } }, status: 400 if validation.failure?
  end

  def csv_invalid_response(error)
    render json: { error: }, status: 422
  end
end
