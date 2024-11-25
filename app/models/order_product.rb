class OrderProduct
  include Mongoid::Document

  field :_id, type: Object
  field :product_id, type: BSON::ObjectId
  field :product_name, type: String
  field :price, type: Integer
  field :quantity, type: Integer

  embedded_in :order

  attr_writer :product

  before_validation :set_product_attributes

  validates :product_id, :product_name, presence: true
  validates :price, :quantity, numericality: { only_integer: true, greater_than: 0 }

  def product
    @product ||= Product.find product_id
  end

  private

  def set_product_attributes
    self.product_id = product.id
    self.product_name = product.name
    self.price = product.default_price # TODO: change to dynamic price
  end
end
