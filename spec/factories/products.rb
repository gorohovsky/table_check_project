FactoryBot.define do
  factory :product do
    name { 'Sample product' }
    default_price { 600 }
    demand { 20 }
    stock { 500 }
    category
  end

  trait :low_demand do
    demand { 20 }
  end

  trait :medium_demand do
    demand { 50 }
  end

  trait :high_demand do
    demand { 100 }
  end

  trait :low_stock do
    stock { 20 }
  end

  trait :medium_stock do
    stock { 50 }
  end

  trait :high_stock do
    stock { 500 }
  end

  trait :very_high_stock do
    stock { 1000 }
  end
end
