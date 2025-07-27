class Order < ApplicationRecord
  validates :customer_id, :product_name, :quantity, :price, :status, presence: true
end
