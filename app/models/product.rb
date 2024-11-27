class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :default_price, type: Integer
  field :stock, type: Integer, default: 0
  field :demand, type: Integer, default: 0
  index({ name: 1, category_id: 1 }, { unique: true })

  belongs_to :category

  validates :name, presence: true
  validates :name, uniqueness: { scope: :category }
  validates :default_price, numericality: { only_integer: true, greater_than: 0 }
  validates :stock, :demand, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  CACHE_KEY_TEMPLATE = 'competing_prices/%s'.freeze
  CACHE_TTL = 3.hours.to_i

  MEDIUM_STOCK_LEVEL = 50
  HIGH_STOCK_LEVEL = 500
  VERY_HIGH_STOCK_LEVEL = 1000

  DEMAND_TO_DAILY_PURCHASES = { low: 1..3, medium: 4..9, high: 10.. }.freeze

  %i[medium high].each do |level|
    const_set("#{level.upcase}_DEMAND_LEVEL", DEMAND_TO_DAILY_PURCHASES[level].first * 10)
  end

  DEMAND_INCREASE_STEP = { cart: 1, purchase: 10 }.freeze

  def orders
    Order.any_of('order_products.product_id' => id)
  end

  def competing_price
    Rails.cache.read cache_key
  end

  def update_competing_price(value)
    Rails.cache.write(cache_key, value, expires_in: CACHE_TTL)
  end

  def stock_level
    case stock
    when (VERY_HIGH_STOCK_LEVEL..)
      :very_high
    when HIGH_STOCK_LEVEL...VERY_HIGH_STOCK_LEVEL
      :high
    when MEDIUM_STOCK_LEVEL...HIGH_STOCK_LEVEL
      :medium
    when ...MEDIUM_STOCK_LEVEL
      :low
    end
  end

  def demand_level
    case demand
    when (HIGH_DEMAND_LEVEL..)
      :high
    when MEDIUM_DEMAND_LEVEL...HIGH_DEMAND_LEVEL
      :medium
    when ...MEDIUM_DEMAND_LEVEL
      :low
    end
  end

  def purchase!(product_quantity)
    reduce_stock_by product_quantity
    increment_demand :purchase
    save!
  end

  def reduce_stock_by(quantity)
    self.stock = stock - quantity
  end

  def increment_demand(event)
    self.demand = demand + DEMAND_INCREASE_STEP[event]
  end

  def increment_demand!(event)
    increment_demand(event) && save!
  end

  private

  def cache_key
    format CACHE_KEY_TEMPLATE % id
  end
end
