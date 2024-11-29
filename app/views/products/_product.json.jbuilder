json.id product.id
json.name product.name
json.category product.category.name
json.stock product.stock
json.default_price cents_to_dollars(product.default_price)
json.competing_price cents_to_dollars(product.competing_price)
json.price cents_to_dollars(product.dynamic_price)
json.demand product.demand
