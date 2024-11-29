json.id order.id
json.products do
  json.array! order.order_items do |item|
    json.product_id item[:product_id]
    json.product_name item[:product_name]
    json.quantity item[:quantity]
    json.price cents_to_dollars(item[:price])
  end
end
json.total cents_to_dollars(order.total)
