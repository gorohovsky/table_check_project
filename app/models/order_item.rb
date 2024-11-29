class OrderItem
  include Mongoid::Document

  field :_id
  field :product_id, type: BSON::ObjectId
  field :product_name, type: String
  field :price, type: Integer
  field :quantity, type: Integer

  embedded_in :order

  attr_writer :product

  after_build :set_product_attributes

  validates :product_id, :product_name, presence: true
  validates :price, :quantity, numericality: { only_integer: true, greater_than: 0 }

  def product
    @product ||= Product.find product_id
  end

  def purchase!
    product.purchase! quantity
  end

  def total_price = quantity * price

  private

  def set_product_attributes
    self.product_id = product.id
    self.product_name = product.name
    self.price = product.dynamic_price.round
  end
end
