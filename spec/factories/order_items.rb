FactoryBot.define do
  factory :order_item do
    transient do
      product { create(:product) }
    end

    product_id { product.id }
    product_name { product.name }
    quantity { 1 }
    price { product.dynamic_price.round }
  end
end
