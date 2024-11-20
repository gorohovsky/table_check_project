FactoryBot.define do
  factory :product do
    name { 'Sample product' }
    default_price { 600 }
    stock { 100 }
    category
  end
end
