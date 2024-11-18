require 'csv'

class ProductImportService
  COLUMN_MAPPING = { name: 'NAME', default_price: 'DEFAULT_PRICE', stock: 'QTY' }.freeze
  PARSING_OPTIONS = { headers: true, return_headers: false }.freeze

  def initialize(csv_file)
    @csv_file = csv_file
  end

  # TODO: check for empty and malformatted (no header, another file type) files
  def process
    Product.transaction do
      CSV.foreach(@csv_file, **PARSING_OPTIONS) do |row|
        category = Category.find_or_create_by!(name: row['CATEGORY'])
        category.products.create! product_attrs(row)
      end
    end
  ensure
    @csv_file.close
  end

  private

  def product_attrs(row)
    COLUMN_MAPPING.transform_values { row[_1] }
  end
end
