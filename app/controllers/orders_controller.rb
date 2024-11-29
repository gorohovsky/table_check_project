class OrdersController < ApplicationController
  rescue_from OrderCreationService::ProductsNotFound, with: :order_creation_error

  before_action :validate_params, only: :create

  def index
    @orders = Order.all
  end

  def show
    @order = Order.find(params[:id])
  end

  def create
    @order = OrderCreationService.new(products_params).execute
    render 'orders/create', status: 201
  end

  private

  def products_params
    @valid_params.dig(:order, :products)
  end

  def order_creation_error(error)
    render json: { errors: error.message }, status: 400
  end
end
