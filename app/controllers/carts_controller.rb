class CartsController < ApplicationController
  before_action :validate_params, :set_cart, only: :add_product

  def show
    render json: Cart.find(params[:id])
  end

  def add_product
    product = Product.find(params[:product_id])
    quantity = params[:quantity]

    @cart.add_product!(product, quantity)
    render json: @cart
  end

  private

  def validate_params
    validation = validation_schema.call(params.to_unsafe_h)
    render json: { errors: validation.messages.to_h }, status: 400 if validation.failure?
  end

  def set_cart
    @cart = Cart.where(id: params[:cart_id]).first || Cart.create!
  end
end
