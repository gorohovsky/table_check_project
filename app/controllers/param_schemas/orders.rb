module ParamSchemas
  module Orders
    Create = Dry::Schema.Params do
      required(:order).filled(:hash) do
        required(:products).value(:array, min_size?: 1).each do
          hash do
            required(:id).filled(:string)
            required(:qty).filled(:integer, gt?: 0)
          end
        end
      end
    end
  end
end
