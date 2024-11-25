class OrderCreationService
  include Errors::Order

  def initialize(order_params)
    @order_params = order_params
  end

  def execute
    raise ProductsNotFound unless products_exist?

    order.save_updating_products!
    order
  end

  private

  def products_exist?
    products.count == @order_params.count
  end

  def products
    @products ||= Product.where(id: { '$in' => product_ids }).to_a
  end

  def product_ids
    @order_params.map { _1[:id] }
  end

  def order
    @order ||= Order.new(products: build_products_hash)
  end

  def build_products_hash
    @order_params.each_with_object({}) do |param, result|
      product = products.detect { _1.id.to_s == param[:id] }
      result[product] = param[:qty]
    end
  end
end
