products, categories = @records.partition { _1.is_a? Product }

json.array! products do |product|
  json.id product.id
  json.name product.name

  category = categories.detect { _1.id == product.category_id }

  json.category category&.name || product.category.name
  json.stock product.stock
  json.default_price cents_to_dollars(product.default_price)
end
