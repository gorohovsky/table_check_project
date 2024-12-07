FactoryBot.define do
  factory :category do
    name { "#{Faker::Commerce.department} #{rand(1000)}" }
  end
end
