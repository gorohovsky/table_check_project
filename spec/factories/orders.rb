FactoryBot.define do
  factory :order do
    products { {} }
    created_at { 1.hour.ago }

    to_create { |instance| instance.save_updating_products! }
  end
end
