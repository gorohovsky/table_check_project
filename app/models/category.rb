class Category
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  index({ name: 1 }, { unique: true })

  has_many :products

  validates :name, presence: true
end
