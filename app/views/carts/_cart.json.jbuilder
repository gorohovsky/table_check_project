json.id cart.id
json.products do
  json.array! cart.cart_items do |item|
    json.product_id item[:product_id]
    json.quantity item[:quantity]
  end
end
json.total cents_to_dollars(cart.calculate_total)
