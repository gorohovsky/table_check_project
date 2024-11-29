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

  def validate_params
    validation = validation_schema.call(params.to_unsafe_h)

    if validation.success?
      @valid_params = validation.to_h
    else
      render json: { errors: validation.messages.to_h }, status: 400
    end
  end

  def products_params
    @valid_params.dig(:order, :products)
  end

  def order_creation_error(error)
    render json: { errors: error.message }, status: 400
  end
end
