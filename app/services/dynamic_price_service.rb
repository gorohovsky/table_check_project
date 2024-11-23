# The rule: dynamic price must not exceed the price cap or competing price, and cannot fall below product's default price.
class DynamicPriceService
  delegate :default_price, :demand_level, :stock_level, to: :@product

  STOCK_FACTORS = { low: '0.2'.to_d, medium: '0.1'.to_d, high: '0'.to_d, very_high: '-0.1'.to_d }.freeze
  DEMAND_FACTORS = { low: '0'.to_d, medium: '0.1'.to_d, high: '0.2'.to_d }.freeze
  PRICE_CAP_MULTIPLIER = '1.3'.to_d

  def initialize(product)
    @product = product
    @competing_price = product.competing_price
  end

  def calculate
    prices = [@competing_price, dynamic_price, price_cap].compact
    return default_price if prices.any? { _1 < default_price }

    prices.min
  end

  private

  def dynamic_price
    default_price * dynamic_factor
  end

  def price_cap
    default_price * PRICE_CAP_MULTIPLIER
  end

  def dynamic_factor
    1 + demand_factor + remaining_stock_factor
  end

  def demand_factor
    DEMAND_FACTORS[demand_level]
  end

  def remaining_stock_factor
    STOCK_FACTORS[stock_level]
  end
end
