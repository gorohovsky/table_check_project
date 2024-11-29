class OrderCreationService
  include Errors::Order

  def initialize(order_params)
    @order = Order.new
    @order_params = order_params
  end

  def execute
    raise ProductsNotFound unless products_exist?

    @order_params.each do |param|
      product = product(param[:id])
      @order.add_product(product, param[:qty])
    end

    @order.save_updating_products!
    @order
  end

  private

  def products_exist?
    products.count == @order_params.size
  end

  def products
    @products ||= Product.where(id: { '$in' => product_ids }).to_a
  end

  def product_ids
    @order_params.map { _1[:id] }
  end

  def product(id)
    products.detect { _1.id.to_s == id }
  end
end
