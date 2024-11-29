class CartsController < ApplicationController
  before_action :validate_params, :set_cart, only: :add_product

  def show
    @cart = Cart.find(params[:id])
  end

  def add_product
    product = Product.find(@valid_params[:product_id])
    quantity = @valid_params[:quantity]

    @cart.add_product!(product, quantity)
  end

  private

  def set_cart
    @cart = Cart.where(id: params[:cart_id]).first || Cart.create!
  end
end
