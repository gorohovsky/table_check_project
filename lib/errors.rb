module Errors
  module Order
    class ProductsNotFound < StandardError
      def message = 'Provided invalid products'
    end
  end
end
