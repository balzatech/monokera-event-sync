class Customer < ApplicationRecord
  validates :name, :address, presence: true
  before_validation :set_default_orders_count, on: :create
  
  def has_orders?
    orders_count > 0
  end
  
  def increment_orders!
    increment!(:orders_count)
  end
  
  def invalidate_cache
    Rails.cache.delete("customer:#{id}")
  end
  
  private
  
  def set_default_orders_count
    self.orders_count ||= 0
  end
end