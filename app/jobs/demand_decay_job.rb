class DemandDecayJob < ApplicationJob
  queue_as :default

  HIGH_DECAY = 10
  MEDIUM_DECAY = 5
  LOW_DECAY = 2
  NO_DECAY = 0

  def perform
    products.each do |product|
      order_count = product.orders.where(:created_at.gte => 24.hours.ago.beginning_of_hour).count

      decay_value = calculate_decay(order_count)

      product.demand = [product.demand - decay_value, 0].max
      product.save!
    end
  end

  private

  def products = Product.where(:demand.gt => 0)

  def calculate_decay(order_count)
    case order_count
    when order_count(:high)
      NO_DECAY
    when order_count(:medium)
      LOW_DECAY
    when order_count(:low)
      MEDIUM_DECAY
    else
      HIGH_DECAY
    end
  end

  def order_count(level)
    Product::DEMAND_TO_DAILY_PURCHASES[level]
  end
end
