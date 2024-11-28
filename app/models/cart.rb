class Cart
  include Mongoid::Document
  include Mongoid::Timestamps

  field :cart_items, type: Array, default: []
  index({ 'cart_items.product_id' => 1 })

  validate :validate_cart_items

  def add_product!(product, quantity)
    transaction do
      populate_cart_items(product.id, quantity)
      product.increment_demand! :cart
      save!
    end
  end

  def calculate_total
    products.sum do |product|
      product.dynamic_price * find_cart_item(product.id)[:quantity]
    end
  end

  def products
    Product.where(id: { '$in' => cart_items.collect { _1[:product_id] } })
  end

  private

  def find_cart_item(product_id)
    cart_items.detect { _1[:product_id] == product_id }
  end

  def populate_cart_items(product_id, quantity)
    if (existing_item = find_cart_item(product_id))
      existing_item[:quantity] += quantity
    else
      cart_items << { product_id:, quantity: }
    end
  end

  def validate_cart_items
    cart_items.each_with_index do |item, i|
      quantity = item[:quantity]
      next if quantity.is_a?(Integer) && quantity.positive?

      errors.add(:cart_items, "Quantity must be a positive integer at index #{i}")
    end
  end
end
