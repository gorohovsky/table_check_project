class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  field :total, type: Integer, default: 0
  index({ created_at: 1 })
  index({ 'order_items.product_id' => 1 })

  embeds_many :order_items

  before_validation :calculate_total

  validates :order_items, presence: true
  validates :total, numericality: { only_integer: true, greater_than: 0 }

  def save_updating_products!
    transaction do
      order_items.each(&:purchase!)
      save!
    end
  end

  def add_product(product, quantity)
    order_items.build(product:, quantity:)
  end

  private

  def calculate_total
    self.total = order_items.sum(&:total_price)
  end
end
