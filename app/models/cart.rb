class Cart
  include Mongoid::Document
  include Mongoid::Timestamps

  field :products, type: Array, default: []
  field :total, type: Integer, default: 0
  index({ 'products.product_id' => 1 })

  validates :total, numericality: { greater_than_or_equal_to: 0 }
  validate :validate_product_entries

  def add_product!(product, quantity)
    transaction do
      populate_cart_products(product, quantity)
      adjust_total(product, quantity)
      product.increment_demand! :cart
      save!
    end
  end

  private

  def populate_cart_products(product, quantity)
    existing_product = products.detect { _1[:product_id] == product.id }

    if existing_product
      existing_product[:quantity] += quantity
    else
      products << { product_id: product.id, quantity: quantity }
    end
  end

  def adjust_total(product, quantity)
    self.total += product.default_price * quantity # TODO: change to the dynamic price
  end

  def validate_product_entries
    products.each_with_index do |product, i|
      quantity = product[:quantity]
      next if quantity.is_a?(Integer) && quantity.positive?

      errors.add(:products, "Quantity must be a positive integer at index #{i}")
    end
  end
end
