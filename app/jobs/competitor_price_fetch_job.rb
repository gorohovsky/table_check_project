class CompetitorPriceFetchJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5
  sidekiq_retry_in { |retry_count| 10 * (retry_count + 1) }

  def perform
    retrieve_prices
    update_cache
  end

  private

  def retrieve_prices
    @data = CompetitorApi::Client.fetch_data
  end

  def update_cache
    @data.each_slice(100) do |entries|
      products = find_matching_products(entries)

      products.each do |product|
        entry = pick_corresponding_entry(entries, product.name, product.category.name)
        product.update_competing_price entry['price'].to_i
      end
    end
  end

  def find_matching_products(entries)
    Product.where(name: { '$in' => entries.collect { _1['name'] } }).includes(:category)
  end

  def pick_corresponding_entry(entries, product_name, product_category)
    entries.detect { _1['name'] == product_name && _1['category'] == product_category }
  end
end
