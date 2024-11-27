class ProductsController < ApplicationController
  rescue_from CSV::MalformedCSVError, with: :csv_invalid_response

  before_action :validate_params, only: :import

  def index
    render json: Product.all
  end

  def show
    render json: Product.find(params[:id])
  end

  def import
    ProductImportService.new(params[:csv].tempfile).process
    head 200 # TODO: return created records or their number
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
