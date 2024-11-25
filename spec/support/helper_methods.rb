def products_to_order_params(products, quantity = 1)
  products.map.with_index do |product, i|
    {
      id: product.id.to_s,
      qty: quantity * (i + 1)
    }
  end
end
