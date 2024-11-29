FactoryBot.define do
  factory :order do
    transient do
      products { [] }
      quantity { 1 }
    end

    order_items do
      products.map do |product|
        build(:order_item, product:, quantity:)
      end
    end

    created_at { 1.hour.ago }

    to_create { |instance| instance.save_updating_products! }
  end
end
