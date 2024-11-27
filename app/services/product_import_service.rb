require 'csv'

class ProductImportService
  HEADER = %w(NAME CATEGORY DEFAULT_PRICE QTY).freeze
  PARSING_OPTIONS = { headers: true, return_headers: false }.freeze
  PRODUCT_COLUMN_MAPPING = { name: 'NAME', default_price: 'DEFAULT_PRICE', stock: 'QTY' }.freeze

  def initialize(csv_file)
    @csv_file = csv_file
  end

  def process
    validate_content!

    Product.transaction do
      CSV.foreach(@csv_file, **PARSING_OPTIONS) do |row|
        category = Category.find_or_create_by!(name: row['CATEGORY'])
        category.products.create! product_attributes(row)
      end
    end
  ensure
    @csv_file.close
  end

  private

  def validate_content!
    check_header!
    check_data_presence!
  end

  def check_header!
    raise CSV::MalformedCSVError.new('File must contain header', 0) unless contains_header?
  end

  def check_data_presence!
    raise CSV::MalformedCSVError.new('File must contain records', 1) unless contains_records?
  end

  def contains_records?
    File.foreach(@csv_file).count > 1
  end

  def contains_header?
    first_row == HEADER
  end

  def first_row
    CSV.foreach(@csv_file).first
  end

  def product_attributes(row)
    PRODUCT_COLUMN_MAPPING.transform_values { row[_1] }
  end
end
