class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  field :total, type: Integer, default: 0
  index({ created_at: 1 })
  index({ 'order_products.product_id' => 1 })

  embeds_many :order_products # TODO: change to array of hashes

  attr_accessor :products

  validates :order_products, presence: true
  validates :total, numericality: { only_integer: true, greater_than: 0 }

  def save_updating_products!
    transaction do
      products.each_pair do |product, quantity|
        product.purchase! quantity
        populate_order_info(product, quantity)
      end
      save!
    end
  end

  private

  def populate_order_info(product, quantity)
    order_products.build(product:, quantity:)
    self.total += product.default_price * quantity
  end
end
