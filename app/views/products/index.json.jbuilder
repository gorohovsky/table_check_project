json.array! @products do |product|
  json.partial! product, partial: 'product', as: :product
end
