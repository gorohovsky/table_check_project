class OrdersController < ApplicationController
  rescue_from OrderCreationService::ProductsNotFound, with: :order_creation_error

  before_action :validate_params, only: :create

  def index
    render json: Order.all
  end

  def show
    render json: Order.find(params[:id])
  end

  def create
    @order = OrderCreationService.new(products_params).execute

    render json: @order, status: 201, location: @order
  end

  private

  def order_params
    params.slice(:order).to_unsafe_h
  end

  def validate_params
    validation = ParamSchemas::Orders::Create.call(order_params)

    if validation.success?
      @valid_params = validation.to_h
    else
      render json: { errors: validation.messages.to_h }, status: 400 # TODO: prettify error messages
    end
  end

  def products_params
    @valid_params.dig(:order, :products)
  end

  def order_creation_error(error)
    render json: { errors: error.message }, status: 400
  end
end
