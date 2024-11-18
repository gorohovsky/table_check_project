class ProductsController < ApplicationController
  def index
    render json: Product.all
  end

  def show
    render json: Product.find(params[:id])
  end

  def import
    render json: ProductImportService.new(params[:csv].tempfile).process
  rescue Mongoid::Errors::MongoidError => e
    render json: PrettyMongoidError.new(e), status: 400
  end
end
