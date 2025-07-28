class Order < ApplicationRecord
  validates :customer_id, :product_name, :quantity, :price, :status, presence: true
  before_validation :set_default_status, on: :create

  def total_amount
    quantity * price
  end

  private
  
  def set_default_status
    self.status ||= 'pending'
  end
end
