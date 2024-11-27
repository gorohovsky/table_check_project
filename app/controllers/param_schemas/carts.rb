module ParamSchemas
  module Carts
    AddProduct = Dry::Schema.Params do
      optional(:cart_id).filled(:string)
      required(:product_id).filled(:string)
      required(:quantity).filled(:integer, gt?: 0)
    end
  end
end
