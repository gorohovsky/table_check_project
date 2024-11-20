class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :default_price, type: Integer
  field :stock, type: Integer
  index({ name: 1, category_id: 1 }, { unique: true })

  belongs_to :category

  validates :name, presence: true
  validates :default_price, numericality: { only_integer: true, greater_than: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  CACHE_KEY_TEMPLATE = 'competing_prices/%s'.freeze
  CACHE_TTL = 3.hours.to_i

  def competing_price
    Rails.cache.read cache_key
  end

  def update_competing_price(value)
    Rails.cache.write(cache_key, value, expires_in: CACHE_TTL)
  end

  private

  def cache_key
    format CACHE_KEY_TEMPLATE % id
  end
end
